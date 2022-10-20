import copy
import io
import json
import logging
import os
import uuid

import environ
from six import string_types

from ..common import (
    APPLICATION_INSTANCE, create_resource, datetime_to_float,
    datetime_to_string, determine_spec_version, determine_version, find_att,
    generate_status, generate_status_details,
    get_application_instance_config_values, get_timestamp, iterpath,
    string_to_datetime
)
from ..exceptions import InitializationError, ProcessingError
from ..filters.basic_filter import BasicFilter
from .base import Backend

# Module-level logger
log = logging.getLogger(__name__)


def remove_hidden_field(objs):
    for obj in objs:
        if "_date_added" in obj:
            del obj["_date_added"]


def find_headers(headers, manifest, obj):
    obj_time = find_att(obj)
    for man in manifest:
        if man["id"] == obj["id"] and obj_time == find_att(man):
            if len(headers) == 0:
                headers["X-TAXII-Date-Added-First"] = man["date_added"]
            else:
                headers["X-TAXII-Date-Added-Last"] = man["date_added"]


class MemoryBackend(Backend):

    # access control is handled at the views level

    @environ.config(prefix="MEMORY")
    class Config(object):
        filename = environ.var(None)

    def __init__(self, **kwargs):
        # Refuse to run under a WSGI server since this is an internal backend
        if (
            "SERVER_SOFTWARE" in os.environ and
            kwargs.get("force_wsgi", False) is not True
        ):
            raise RuntimeError(
                "The memory backend should not be run by a WSGI server since "
                "it does not provide an external data backend. "
                "Set the 'force_wsgi' backend option to true to skip this."
            )
        if kwargs.get("filename"):
            self.load_data_from_file(kwargs.get("filename"))
            self.collections_manifest_check()
        else:
            self.data = {}
        super(MemoryBackend, self).__init__(**kwargs)

    def _pop_expired_sessions(self):
        expired_ids = []
        boundary = datetime_to_float(get_timestamp())
        for next_id, record in self.next.items():
            if boundary - record["request_time"] > self.timeout:
                expired_ids.append(next_id)

        for item in expired_ids:
            self.next.pop(item)

    def _pop_old_statuses(self):
        api_roots = self._get_all_api_roots()
        boundary = datetime_to_float(get_timestamp())
        for ar in api_roots:
            statuses_of_api_root = copy.copy(self._get_api_root_statuses(ar))
            for s in statuses_of_api_root:
                if boundary - datetime_to_float(string_to_datetime(s["request_timestamp"])) > self.status_retention:
                    self._get_api_root_statuses(ar).remove(s)
                    log.info("Status {} was deleted from {} because it was older than the status retention time".format(s['id'], ar))

    def set_next(self, objects, args):
        u = str(uuid.uuid4())
        if "limit" in args:
            del args["limit"]
        for arg in args:
            new_list = args[arg].split(',')
            new_list.sort()
            args[arg] = new_list
        d = {"objects": objects, "args": args, "request_time": datetime_to_float(get_timestamp())}
        self.next[u] = d
        return u

    def get_next(self, filter_args, allowed, manifest, lim):
        n = filter_args["next"]
        if n in self.next:
            for arg in filter_args:
                new_list = filter_args[arg].split(',')
                new_list.sort()
                filter_args[arg] = new_list
            del filter_args["next"]
            del filter_args["limit"]
            if filter_args != self.next[n]["args"]:
                raise ProcessingError("The server did not understand the request or filter parameters: params changed over subsequent transaction", 400)
            t = self.next[n]["objects"]
            length = len(self.next[n]["objects"])
            headers = {}
            ret = []
            if length <= lim:
                limit = length
                more = False
                nex = None
            else:
                limit = lim
                more = True

            for i in range(0, limit):
                x = t.pop(0)
                ret.append(x)
                if len(headers) == 0:
                    find_headers(headers, manifest, x)
                if i == limit - 1:
                    find_headers(headers, manifest, x)
            if not more:
                self.next.pop(n)
            else:
                nex = n

            return ret, more, headers, nex
        else:
            raise ProcessingError("The server did not understand the request or filter parameters: 'next' not valid", 400)

    def collections_manifest_check(self):
        """
        Checks collections for proper manifest, if objects are present in a collection, a manifest should be present with
        an entry for each entry in objects
        """

        for key, api_root in self.data.items():
            for collection in api_root.get('collections', []):
                if not collection.get('objects'):
                    continue
                if 'manifest' not in collection:
                    raise InitializationError("Collection {} manifest is missing".format(collection['id']), 408)
                if not collection['manifest']:
                    raise InitializationError("Collection {} with objects has an empty manifest".format(collection['id']), 408)
                for obj in collection.get('objects', []):
                    obj_time = find_att(obj)
                    obj_man_paired = False
                    for man in collection['manifest']:
                        man_time = find_att(man)
                        if obj['id'] == man['id'] and obj_time == man_time:
                            obj_man_paired = True
                            break
                    if not obj_man_paired:
                        raise InitializationError("Object with id {} from {} is missing a manifest".format(obj['id'], obj_time), 408)

    def load_data_from_file(self, filename):
        if isinstance(filename, string_types):
            with io.open(filename, "r", encoding="utf-8") as infile:
                self.data = json.load(infile)
        else:
            self.data = json.load(filename)

    def save_data_to_file(self, filename, **kwargs):
        """The kwargs are passed to ``json.dump()`` if provided."""
        if isinstance(filename, string_types):
            with io.open(filename, "w", encoding="utf-8") as outfile:
                json.dump(self.data, outfile, **kwargs)
        else:
            json.dump(self.data, filename, **kwargs)

    def _get(self, key):
        for ancestors, item in iterpath(self.data):
            if key in ancestors:
                return item

    def server_discovery(self):
        return self._get("/discovery")

    def _update_manifest(self, new_obj, api_root, collection_id, request_time):
        api_info = self._get(api_root)
        collections = api_info.get("collections", [])
        media_type_fmt = "application/stix+json;version={}"

        for collection in collections:
            if collection_id == collection["id"]:
                version = determine_version(new_obj, request_time)
                request_time = datetime_to_string(request_time)
                media_type = media_type_fmt.format(determine_spec_version(new_obj))

                # version is a single value now, therefore a new manifest is always created
                collection["manifest"].append(
                    {
                        "id": new_obj["id"],
                        "date_added": request_time,
                        "version": version,
                        "media_type": media_type,
                    },
                )

                # if the media type is new, attach it to the collection
                if media_type not in collection["media_types"]:
                    collection["media_types"].append(media_type)

                # quit once you have found the collection that needed updating
                break

    def get_collections(self, api_root):
        if api_root not in self.data:
            return None  # must return None so 404 is raised

        api_info = self._get(api_root)
        collections = copy.deepcopy(api_info.get("collections", []))

        # Remove data that is not part of the response.
        for collection in collections:
            collection.pop("manifest", None)
            collection.pop("responses", None)
            collection.pop("objects", None)
        # interop wants results sorted by id
        if get_application_instance_config_values(APPLICATION_INSTANCE, "taxii", "interop_requirements"):
            collections = sorted(collections, key=lambda o: o["id"])
        return create_resource("collections", collections)

    def get_collection(self, api_root, collection_id):
        if api_root not in self.data:
            return None  # must return None so 404 is raised

        api_info = self._get(api_root)
        collections = copy.deepcopy(api_info.get("collections", []))

        for collection in collections:
            if collection_id == collection["id"]:
                collection.pop("manifest", None)
                collection.pop("responses", None)
                collection.pop("objects", None)
                return collection

    def get_object_manifest(self, api_root, collection_id, filter_args, allowed_filters, limit):
        more = False
        n = None
        if api_root in self.data:
            api_info = self._get(api_root)
            collections = api_info.get("collections", [])

            for collection in collections:
                if collection_id == collection["id"]:
                    if "next" in filter_args:
                        manifest = collection.get("manifest", [])
                        manifest, more, headers, n = self.get_next(filter_args, allowed_filters, manifest, limit)
                    else:
                        manifest = collection.get("manifest", [])
                        full_filter = BasicFilter(filter_args)
                        manifest, next_save, headers = full_filter.process_filter(
                            manifest,
                            allowed_filters,
                            None,
                            limit
                        )
                        if len(next_save) != 0:
                            more = True
                            n = self.set_next(next_save, filter_args)
                        break
            return create_resource("objects", manifest, more, n), headers

    def get_api_root_information(self, api_root):
        if api_root in self.data:
            api_info = self._get(api_root)

            if "information" in api_info:
                return api_info["information"]

    def _get_api_root_statuses(self, api_root):
        api_info = self._get(api_root)

        if "status" in api_info:
            return api_info["status"]

    def get_status(self, api_root, status_id):
        if api_root in self.data:
            api_info = self._get(api_root)

            for status in api_info.get("status", []):
                if status_id == status["id"]:
                    return status

    def get_objects(self, api_root, collection_id, filter_args, allowed_filters, limit):
        more = False
        n = None
        if api_root in self.data:
            api_info = self._get(api_root)
            collections = api_info.get("collections", [])
            objs = []
            for collection in collections:
                if collection_id == collection["id"]:
                    manifest = collection.get("manifest", [])
                    if "next" in filter_args:
                        objs, more, headers, n = self.get_next(filter_args, allowed_filters, manifest, limit)
                    else:
                        objs = copy.deepcopy(collection.get("objects", []))
                        full_filter = BasicFilter(filter_args)
                        objs, next_save, headers = full_filter.process_filter(
                            objs,
                            allowed_filters,
                            manifest,
                            limit
                        )

                        if len(next_save) != 0:
                            more = True
                            n = self.set_next(next_save, filter_args)
                        break
            remove_hidden_field(objs)
            return create_resource("objects", objs, more, n), headers

    def _add_status(self, api_root_name, status):
        self._get_api_root_statuses(api_root_name).append(status)

    def add_objects(self, api_root, collection_id, objs, request_time):
        if api_root in self.data:
            api_info = self._get(api_root)
            collections = api_info.get("collections", [])
            failed = 0
            succeeded = 0
            pending = 0
            successes = []
            failures = []

            for collection in collections:
                if collection_id == collection["id"]:
                    if "objects" not in collection:
                        collection["objects"] = []
                    try:
                        for new_obj in objs["objects"]:
                            version = determine_version(new_obj, request_time)
                            id_and_version_already_present = False
                            for obj in collection["objects"]:
                                if new_obj["id"] == obj["id"]:
                                    if "modified" in new_obj:
                                        if new_obj["modified"] == obj["modified"]:
                                            id_and_version_already_present = True
                                            break
                                    else:
                                        # There is no modified field, so this object is immutable
                                        id_and_version_already_present = True
                                        break

                            if id_and_version_already_present:
                                message = "Object already added"

                            else:
                                message = None
                                if "modified" not in new_obj and "created" not in new_obj:
                                    new_obj["_date_added"] = version
                                collection["objects"].append(new_obj)
                                self._update_manifest(new_obj, api_root, collection["id"], request_time)

                            # else: we already have the object, so this is a
                            # no-op.

                            status_details = generate_status_details(
                                new_obj["id"], version, message
                            )
                            successes.append(status_details)
                            succeeded += 1

                    except Exception as e:
                        raise ProcessingError("While processing supplied content, an error occurred", 422, e)

            status = generate_status(
                datetime_to_string(request_time), "complete", succeeded,
                failed, pending, successes=successes,
                failures=failures,
            )
            api_info["status"].append(status)
            return status

    def get_object(self, api_root, collection_id, object_id, filter_args, allowed_filters, limit):
        more = False
        n = None
        if api_root in self.data:
            api_info = self._get(api_root)
            collections = api_info.get("collections", [])
            objs = []
            manifests = []
            for collection in collections:
                if collection_id == collection["id"]:
                    manifests = collection.get("manifest", [])
                    if "next" in filter_args:
                        objs, more, headers, n = self.get_next(filter_args, allowed_filters, manifests, limit)
                    else:
                        for obj in collection.get("objects", []):
                            if object_id == obj["id"]:
                                objs.append(copy.deepcopy(obj))
                        if len(objs) == 0:
                            raise ProcessingError("Object '{}' not found".format(object_id), 404)
                        full_filter = BasicFilter(filter_args)
                        objs, next_save, headers = full_filter.process_filter(
                            objs,
                            allowed_filters,
                            manifests,
                            limit
                        )
                        if len(next_save) != 0:
                            more = True
                            n = self.set_next(next_save, filter_args)
                        break
            remove_hidden_field(objs)
            return create_resource("objects", objs, more, n), headers

    def delete_object(self, api_root, collection_id, obj_id, filter_args, allowed_filters):
        if api_root in self.data:
            api_info = self._get(api_root)
            collections = api_info.get("collections", [])
            objs = []
            manifests = []
            for collection in collections:
                if "id" in collection and collection_id == collection["id"]:
                    coll = collection.get("objects", [])
                    for obj in coll:
                        if obj_id == obj["id"]:
                            objs.append(obj)
                    manifests = collection.get("manifest", [])
                    break

            full_filter = BasicFilter(filter_args)
            objs, nex, headers = full_filter.process_filter(
                objs,
                allowed_filters,
                manifests,
                None
            )

            if len(objs) == 0:
                raise ProcessingError("Object '{}' not found".format(obj_id), 404)

            for obj in objs:
                if obj in coll:
                    coll.remove(obj)
                    obj_time = find_att(obj)
                    for man in manifests:
                        if obj["id"] == man["id"] and obj_time == find_att(man):
                            manifests.remove(man)
                            break

    def get_object_versions(self, api_root, collection_id, object_id, filter_args, allowed_filters, limit):
        more = False
        n = None
        if api_root in self.data:
            api_info = self._get(api_root)
            collections = api_info.get("collections", [])

            objs = []
            for collection in collections:
                if collection_id == collection["id"]:
                    all_manifests = collection.get("manifest", [])
                    if "next" in filter_args:
                        objs, more, headers, n = self.get_next(filter_args, allowed_filters, all_manifests, limit)
                        objs = sorted(map(lambda x: x["version"], objs), reverse=True)
                    else:

                        all_manifests = collection.get("manifest", [])
                        for manifest in all_manifests:
                            if object_id == manifest["id"]:
                                objs.append(manifest)
                        if len(objs) == 0:
                            raise ProcessingError("Object '{}' not found".format(object_id), 404)
                        full_filter = BasicFilter(filter_args)
                        objs, next_save, headers = full_filter.process_filter(
                            objs,
                            allowed_filters,
                            None,
                            limit
                        )
                        if len(next_save) != 0:
                            more = True
                            n = self.set_next(next_save, filter_args)
                        objs = sorted(map(lambda x: x["version"], objs), reverse=True)
                        break
            return create_resource("versions", objs, more, n), headers
