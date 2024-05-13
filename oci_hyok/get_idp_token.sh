#!/usr/bin/env bash
set -e

###############################################################################
#
# Fetch the OCI IDP JWT for authorization of OCI HYOK proxy APIs, and with the
# the environment set up from the oci_env file
#
# Usage:
#
#     ./get_idp_token.sh
#
###############################################################################

GRANT_TYPE="client_credentials"
SCOPE="CTMoci_hyok_encrypt"

cmd=$(curl --request POST --url "https://idcs-<id>.identity.oraclecloud.com:443/oauth2/v1/token" --header "content-type: application/x-www-form-urlencoded" --data grant_type=$GRANT_TYPE --data client_id=$IDP_ACCESS_ID --data client_secret=$IDP_SECRET_KEY --data scope=$SCOPE)
echo $cmd
