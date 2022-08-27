#!/usr/bin/env python3

import argparse
import json
import requests
from pprint import pprint

elastic_server_ip = ""
elastic_server_port = ""
elastic_api_key = ""
misp_server_ip = ""
misp_api_key = ""

class Event():
    date = ""
    description = ""
    distribution = {
        "your_organisation_only": 0,
	"this_community_only": 1,
	"connected_communities": 2,
	"all_communities": 3,
	"sharing_group": 4,
	"inherit": 5
    }
    threat_level = {
        "high": 1,
	"medium": 2,
	"low": 3,
	"undefined": 4
    }
    analysis = {
        "initial": 0,
	"ongoing": 1,
        "completed": 2
    }

class Attribute():
    type = ""
    category = ""
    value = ""
    distribution = {
        "your_organisation_only": 0,
	"this_community_only": 1,
	"connected_communities": 2,
	"all_communities": 3,
	"sharing_group": 4,
	"inherit": 5
    }
    for_ids = "false"
    contextual_comment = ""

def get_cases(elastic_server_ip, elastic_server_port, elastic_api_key):
    elastic_server = elastic_server_ip + ":" + elastic_server_port
    authorization = "ApiKey " + elastic_api_key
    url = "https://" + elastic_server + "/so-case/_search?pretty"
    headers = {
        "Content-Type": "application/json;charset=UTF-8",
        "Authorization": authorization
    }
    response_from_elastic = requests.get(url, headers = headers, verify = False)
    events = json.loads(response_from_elastic.text)["hits"]["hits"]
    cases = []
    related = []
    artifacts = []
    for event in events:
        event_type = event["_source"]["so_kind"]
        if event_type == "case":
            cases.append(event)
        elif event_type == "related":
            related.append(event)
        elif event_type == "artifact":
            artifacts.append(event)
    for event in related:
        update = event["_source"]["so_related"]
        for case in cases:
            if update["caseId"] == case["_id"]:
                foo = {
                    "id": case["_id"],
                }
                for detail in case["_source"]["so_case"]:
                    foo[detail] = case["_source"]["so_case"][detail]
                for field in update["fields"]:
                    foo[field] = update["fields"][field]
    return cases

def create_event(case):
    pprint(case)
    event = Event()
    case["_id"]
    case["so_case"]
    # map case details to event
    # for artifact in case:
        # attribute = create_attribute(artifact)
        # add attribute to event
    return event

def create_attribute(artifact):
    pprint(artifact)
    attribute = Attribute()
    attribute._type = "" # artifact["type"], ex: url
    attribute.category = "" # artifact["category"], ex: network activity
    attribute.value = ""
    attribute.distribution = ""
    attribute.for_ids = "false"
    attribute.comment = ""
    return attribute

def publish_event(misp_server_ip, misp_api_key, event):
    url = "https://" + misp_server_ip + "/events"
    headers = {
        "Accept": "application/json",
	"content-type": "application/json",
	"Authorization": misp_api_key
    }
    response = requests.post(url, headers = headers, json = event, verify = False)
    print(response.text)
    return

def main():
    requests.packages.urllib3.disable_warnings()
    cases = get_cases(elastic_server_ip, elastic_server_port, elastic_api_key)
    for case in cases:
        create_event(case)
        # event = create_event(case)
        # publish_event(event)
    return

if __name__ == "__main__":
    main()
