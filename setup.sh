#!/bin/bash

if [[ "$1" == "" ]] || [[ "$2" == "" ]] || [[ "$3" == "" ]]; then
    echo "Usage: source $0 HOSTNAME/IP KSCTL_CONFIG_FILE KSCTL_BINARY GOOGLE_SERVICE_ACCOUNT_FILE"
    echo ""
    echo "  HOSTNAME/IP refers to the hostname/IP of the Kylo server"
    echo ""
    echo "This is just a convenience script which performs all Kylo config changes as needed to run the K6 performance test."
    echo ""
    echo "With this you can basically run something like:"
    echo "  ./setup.sh 192.168.1.185 /home/kozz/kylo-cli/node1.yaml /home/kozz/kylo-cli/ksctl thalescplcto_gcp_service_account.json && source .env && ./verify_setup.sh"
    echo ""
    echo "If the verify returns 200 OK you can then simply run to run the performance test:"
    echo "  ./run.sh"

    exit 1
fi

host="$1"
ksctl_config="$2"
ksctl_binary="$3"
google_service_account_file="$4"

for id in $($ksctl_binary --configfile "$ksctl_config" cckm ekm endpoints list | jq -r ".resources[].id"); do $ksctl_binary --configfile "$ksctl_config" cckm ekm endpoints delete --id $id; done
$ksctl_binary --configfile "$ksctl_config" cckm google projects delete --id test-ekm 2>/dev/null
$ksctl_binary --configfile "$ksctl_config" cckm google projects add --project_id test-ekm
endpoint_data=$($ksctl_binary --configfile $ksctl_config cckm ekm endpoints create --endpointName test --hostName "$host" --ekm-endpoint-policy-jsonfile ekm_policy.js)
echo "Endpoint data: $endpoint_data"

endpoint=$(echo $endpoint_data | jq -r .keyURI)
endpoint_id=$(echo $endpoint_data | jq -r .id)

./ekm_performance_config_setup.sh -f "$host" -e "$endpoint" -a "$google_service_account_file"

