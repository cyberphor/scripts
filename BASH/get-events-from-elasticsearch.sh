#!/bin/bash

ELASTIC_API_KEY=""

curl \
--header "Content-Type: application/json;charset=UTF-8" \
--header "Authorization: ApiKey ${ELASTIC_API_KEY}" \
--location \
--request GET "https://localhost:9200/so-case/_search?pretty" \
-k
