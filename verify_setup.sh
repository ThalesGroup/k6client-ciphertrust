#!/bin/bash

# Assumes G_TOKEN and ENDPOINT_URL are set (from setup.sh)

data='
{
    "plaintext": "test",
    "additionalContext": {
        "accessReasonContext": {
            "reason": "CUSTOMER_INITIATED_SUPPORT"
        },
        "RelativeResourceName": "projects/test-ekm/locations/us/keyRings/n1-key-ring/cryptoKeys/kylo-nv-2/cryptoKeyVersions/16",
        "is_key_health_check": null
    }
}'

data=$(echo $data)

curl -v -k -H "Content-Type: application/json" -H "Authorization: Bearer $G_TOKEN" --data-binary "$data" "$ENDPOINT_URL:wrap"

