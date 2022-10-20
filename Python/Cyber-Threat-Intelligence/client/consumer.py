#!/usr/bin/env python3

import argparse
import stix2

def consume(bundle):
    for obj in bundle.objects:
        if obj == identityAlpha:
            print("------------------")
            print("== IDENTITY ==")
            print("------------------")
            print("ID: " + obj.id)
            print("Created: " + str(obj.created))
            print("Modified: " + str(obj.modified))
            print("Name: " + obj.name)
            print("Roles: " + str(obj.roles))
            print("Identity Class: " + obj.identity_class)
            print("Sectors: " + str(obj.sectors))
            print("Contact Information: " + obj.contact_information)
        elif obj == identityBeta:
            print("------------------")
            print("== IDENTITY ==")
            print("------------------")
            print("ID: " + obj.id)
            print("Created: " + str(obj.created))
            print("Modified: " + str(obj.modified))
            print("Name: " + obj.name)
            print("Roles: " + str(obj.roles))
            print("Identity Class: " + obj.identity_class)
            print("Sectors: " + str(obj.sectors))
            print("Contact Information: " + obj.contact_information)
        elif obj == indicator:
            print("------------------")
            print("== INDICATOR ==")
            print("------------------")
            print("ID: " + obj.id)
            print("Created: " + str(obj.created))
            print("Modified: " + str(obj.modified))
            print("Name: " + obj.name)
            print("Description: " + obj.description)
            print("Type: " + obj.type)
            print("Indicator Types: " + str(obj.indicator_types))
            print("Pattern: " + obj.pattern)
            print("Pattern Type: " + obj.pattern_type)
            print("Valid From: " + str(obj.valid_from))
        elif obj == sighting:
            print("------------------")
            print("== SIGHTING ==")
            print("------------------")
            print("ID: " + obj.id)
            print("Created: " + str(obj.created))
            print("Modified: " + str(obj.modified))
            print("Type: " + obj.type)
            print("Created by Ref: " + obj.created_by_ref)
            print("First Seen: " + str(obj.first_seen))
            print("Last Seen: " + str(obj.last_seen))
            print("Count: " + str(obj.count))
            print("Sighting of Ref: " + obj.sighting_of_ref)
            print("Where Sighted Refs: " + str(obj.where_sighted_refs))

parser = argparse.ArgumentParser()
parser.add_argument("--bundle")
args = parser.parse_args()
consume(args.bundle)
