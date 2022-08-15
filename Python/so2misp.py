#!/usr/bin/env python3

import requests

api_key = ""
ip = ""
url = "https://" + ip + "/events"
headers = {
    "Accept": "application/json",
    "content-type": "application/json",
    "Authorization": api_key
}
event = {
    "Event":{
        "date":"2020-08-14",
        "distribution":3,    # all communities
        "threat_level_id":1, # general
        "analysis":1,        # ongoing
        "info":"Demo",
        "Attribute": [
            {
                "type":"domain",
                "category":"Network activity",
                "value":"https://cyberphor.com",
                "distribution":3,
                "to_ids":"false",
                "comment":"Known bad domain"
            }
        ]
    }
}

response = requests.post(url, headers = headers, json = event, verify = False)
print(response.text)
