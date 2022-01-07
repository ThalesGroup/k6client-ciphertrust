#!/bin/bash -x

duration="30s"

if [[ "$1" != "" ]]; then
    duration="$1"
fi

docker run --rm -i -e G_TOKEN -e ENDPOINT_URL loadimpact/k6 run --vus 170 --duration "$duration" --insecure-skip-tls-verify - < ekm_wrap.js

