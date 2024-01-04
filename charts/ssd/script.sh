#!/bin/sh
server_endpoint=http://localhost:8080/admin/schema
curl -X POST -H "Content-Type: application/json" --data-binary "$(cat /tmp/schema.graphql)" $server_endpoint
