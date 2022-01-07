#!/bin/bash +x

usage ()
{
  echo 'Usage: $0 -f <host_fqdn> -e <ekm_endpoint_url> -a <google_service_account_file>'
  echo 'Example: $0 -f "test-cm.thalescpl.io" -e "https://test-cm.thalescpl.io/api/v1/cckm/ekm/endpoints/fc992707-cfc8-486f-9006-7433c93dfa77" -a "/home/john/Downloads/test-perf-1.json"'
  echo ""
  echo "This script will generate a .env file with the environment needed to run K6 tests"

  exit
}

rm -rf .env

while getopts a:e:f:h option
do
case "${option}" 
in
a)
  accountFile=${OPTARG}
	echo "export GOOGLE_APPLICATION_CREDENTIALS=$accountFile" >> .env
  ;;

e)
  url=${OPTARG}
	echo "export ENDPOINT_URL=$url" >> .env
  ;;

f)
  host_fqdn=${OPTARG}
  ;;
h)
  usage
  ;;
*)
  echo "Unsupported parameter"
  usage
  exit 1
esac
done

# Check for valid inputs
if [ "$accountFile" == "" ] || [ "$url" == "" ] || [ "$host_fqdn" == "" ]; then
  echo "Specify correct values for service account file, endpoint URL and host fqdn !"
  exit 1
fi

# Check if service account file exists
if [ ! -e "$accountFile" ]; then
    echo "Specified file does not exist !"
    exit 1
fi

#generate token
source .env
g_token=$(./get_gcp_token_credentials "$host_fqdn")
if [ "$?" == "0" ]; then
    echo "export G_TOKEN=$g_token" >> .env
    printf "\n%s\n" "Successfully exported env variables for K6 script."
    printf "\n%s\n" "Don't forget to run 'source .env'."
else
#  echo $g_token
    printf "\n%s\n" "Failed to generate Google Token !"
    printf "\n%s\n" "$g_token"
    printf "\n%s\n" "Check if following pre-requisites are met:
    1. Service Account File exists.
    2. Service Account has  'Service Account Token Creator' permission.
    3. Host FQDN does not have 'http' or 'https' prefix."
    exit 1
fi

