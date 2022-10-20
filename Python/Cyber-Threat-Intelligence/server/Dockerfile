FROM alpine:latest

LABEL Author="Victor Fernandez III, @cyberphor"

RUN apk add --no-cache python3 py3-pip

COPY medallion /opt/taxii/medallion

COPY config.d /opt/taxii/medallion/config.d

WORKDIR /opt/taxii/medallion

RUN python3 -m pip install pymongo && \
    python3 -m pip install .
