FROM alpine:latest

LABEL Author="Victor Fernandez III, @cyberphor"

RUN apk add --no-cache python3 py3-pip

RUN python3 -m pip install stix2 medallion taxii2-client 

ENTRYPOINT ["python3"]
