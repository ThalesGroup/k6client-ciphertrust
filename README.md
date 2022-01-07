# About this package

This package contains files required to test Ciphertrust Manager's Google External Key Manager (EKM) service performance.
Run the script in this repository and then run the k6 script to collect EKM performance numbers.

## Recommendation

For best performance, it is recommended to have following:  
- Ciphertrust Manager configuration of >= 4CPU, 16GB memory.  
- Ciphertrust Manager instance hosted in same region/zone as the client machine where k6 is run.  

## Usage for environment configuration
Setup is required for k6 client and Ciphertrust Manager to measure EKM service performance for wrap operation.
This setup can be performed by either of the below methods.
- Script to pre-configure Ciphertrust Manager and create environment for k6.
- Script to create environment for k6 (assuming Ciphertrust Manager is already setup).

### Common prerequisites for both of the above methods
1. Setup Linux system with Ubuntu with bash shell support.

   Other Linux distributions also might work. We have tested with Ubuntu 20.04.3 LTS.

2. Install k6 client from here. Refer to Ubuntu installation steps available at https://k6.io/docs/getting-started/installation/

   Or just use the Docker image. See `run.sh`

3. Install 'jq' utility:


    sudo apt-get update -y; sudo apt-get install -y jq

5. Install Ciphertrust Manager instance, ideally in same region/zone as the Linux system hosting the k6 client.

6. Ensure that Ciphertrust Manager instance is reachable from the machine hosting k6 client.

7. Acquire a `google_service_account_file` for your Google account. It is not located in this repo.

### Method 1: Pre-configure Ciphertrust Manager and create environment for k6
#### Pre-requisites
1. Download the executable for command line utility from top right corner of below page:


    https://{{KYLO_IP_OR_FQDN}}/playground_v2/cli

2. Generate the configuration file for Ciphertrust Manager command line utility using below command:


    cd $EKM_PERFORMANCE_TOOL_REPO
    KSCTL_BINARY login --url=https://{{KYLO_IP_OR_FQDN}} --configfile KSCTL_CONFIG_FILE

   For Example:

    ./ksctl-linux-amd64 login --url=https://test-cm.thalescpl.io --configfile ksctl_config_file.json  

   When prompted, enter 'admin' user credentials to your Ciphertrust Manager instance.
   Config file specified in above command would be generated.

   For Example:  
   On successful execution of above command, file `ksctl_config_file.json` would be created. 

4. Replace value in `clients` field with value of `client_email` from `google_service_account_file` in `ekm_policy.js`

#### Steps for configuration
Below scripts would perform the setup (google project and EKM endpoint) required in Ciphertrust Manager for you and there is no pre-setup needed.

    ./setup.sh HOSTNAME/IP KSCTL_CONFIG_FILE KSCTL_BINARY GOOGLE_SERVICE_ACCOUNT_FILE  
    Above command would delete and recreate google project and EKM endpoint.  

For Example: 

    ./setup.sh test-cm.thalescpl.io ksctl_config_file.json ksctl-linux-amd64 ~/Downloads/test-gcp-service-account.json && source .env && ./verify_setup.sh

    If you see a "200 OK" message from the verification and you get a `wrappedBlob`
    response back you are good to continue.

Above command would generate Google token and EKM endpoint URL as below environment variables:  

    G_TOKEN
    ENDPOINT_URL

5. User can now run the k6 with desired parameters by using environment variables generated in previous step.


     k6 run --stage 5s:70,30s:70,5s:0 ekm_wrap.js -e G_TOKEN=$G_TOKEN -e ENDPOINT_URL=$ENDPOINT_URL  
     Google token has expiry of 1 hour. `setup.sh` script can be re-run to generate new token.  

#### k6 client configuration
Configuration file `ekm_wrap.js` for k6 tool is provided with this package.
This file ensures that wrap or unwrap commands sent by k6 return a 200 response code.  

#### Steps to measure EKM wrap performance  
Refer section `Steps to run k6 client to measure EKM wrap performance`

### Method 2: Create environment for k6 (assuming Ciphertrust Manager is already setup)
#### Pre-requisites
1. Add 'test-ekm' Google project in Ciphertust Manager.


    ./ksctl-linux-amd64 cckm google projects add --project_id test-ekm

2. Create Symmetric EKM endpoint with following policy attributes:


    ./ksctl-linux-amd64 cckm ekm endpoints create --endpointName test --hostName "$host" --ekm-endpoint-policy-jsonfile ekm_policy.js

3. Invoke following script to generate the environment variables:


    ./ekm_performance_config_setup.sh -f "test-cm.thalescpl.io" -e "https://test-cm.thalescpl.io/api/v1/cckm/ekm/endpoints/d73dc773-710e-4c59-b605-411be7c37d68" -a "/home/john/Downloads/test-gcp-service-account.json"
    source .env

Above command would generate  Google token and EKM endpoint URL as below environment variables:  

    G_TOKEN
    ENDPOINT_URL

4. User can now run the k6 with desired parameters by using environment variables generated in previous step.


     k6 run --stage 5s:70,30s:70,5s:0 ekm_wrap.js -e G_TOKEN=$G_TOKEN -e ENDPOINT_URL=$ENDPOINT_URL  
     Google token has expiry of 1 hour. `ekm_performance_config_setup.sh` script can be re-run to generate new token.  

#### Steps for configuration
Create google project and EKM endpoint manually in Ciphertrust Manager and then invoke below script:

    ./ekm_performance_config_setup.sh -f <host_fqdn> -e <ekm_endpoint_url> -a <google_service_account_file>
    source .env

For Example:

    ./ekm_performance_config_setup.sh -f "test-cm.thalescpl.io" -e "https://test-cm.thalescpl.io/api/v1/cckm/ekm/endpoints/fc992707-cfc8-486f-9006-7433c93dfa77" -a "test-gcp-service-account.json"
    source .env

#### k6 client configuration
Configuration file `ekm_wrap.js` for k6 tool is provided with this package.
This file ensures that wrap or unwrap commands sent by k6 return a 200 response code.

#### Steps to measure EKM wrap performance
Refer section `Steps to run k6 client to measure EKM wrap performance`

## Steps to run k6 client to measure EKM wrap performance:
User can run the k6 with desired parameters. k6 client can be run as binary or in docker container.

- Running with k6 binary (include environment variables set as part of previous step `Ciphertrust Manager configuration`)


    k6 run --stage 5s:70,30s:70,5s:0 ekm_wrap.js -e G_TOKEN=$G_TOKEN -e ENDPOINT_URL=$ENDPOINT_URL
    Refer `Common Prerequisites section` for instructions to download k6 client

- Running with docker container


    ./run.sh
    Modify k6 parameters in above file as desired. 

   Above runs k6 from a Docker container and you don't need to install it before. Docker would need to be installed
   on system though.  

   For Example:
   > Change directory to ekm performance tool repo


     k6 run --stage 5s:70,30s:70,5s:0 ekm_wrap.js -e G_TOKEN=$G_TOKEN -e ENDPOINT_URL=$ENDPOINT_URL  

   Above runs the performance with following configuration:  

   - Run test for 40 seconds  
   - Here is the breakup of 40 seconds:  
       => Rampup virtual users up to 70 in 5 seconds,  
       => Maintain 70 virtual users for 30 seconds and  
       => Ramp down to 0 virtual users in 5 seconds.  
   - Send wrap requests from virtual users during above.
   - k6 displays the results after the run is complete. Below is the sample output of k6:  


      ✓ status code
      
      checks.........................: 100.00% ✓ 3304 ✗ 0  
      data_received..................: 4.6 MB  115 kB/s  
      data_sent......................: 4.3 MB  106 kB/s  
      http_req_blocked...............: avg=88µs     min=1.96µs  med=5.34µs   max=47.38ms  p(90)=7.16µs   p(95)=8.45µs  
      http_req_connecting............: avg=13.46µs  min=0s      med=0s       max=1.1ms    p(90)=0s       p(95)=0s  
      http_req_duration..............: avg=33.26ms  min=11.94ms med=27.36ms  max=189.21ms p(90)=56.68ms  p(95)=71.97ms  
      { expected_response:true }...: avg=33.26ms  min=11.94ms med=27.36ms  max=189.21ms p(90)=56.68ms  p(95)=71.97ms  
      http_req_failed................: 0.00%   ✓ 0    ✗ 3304  
      http_req_receiving.............: avg=104.51µs min=28.03µs med=97.56µs  max=2.41ms   p(90)=140.84µs p(95)=168.01µs  
      http_req_sending...............: avg=39.76µs  min=11.34µs med=35.06µs  max=240.49µs p(90)=53.97µs  p(95)=73.68µs  
      http_req_tls_handshaking.......: avg=61.59µs  min=0s      med=0s       max=26.89ms  p(90)=0s       p(95)=0s  
      http_req_waiting...............: avg=33.11ms  min=11.78ms med=27.21ms  max=188.97ms p(90)=56.55ms  p(95)=71.8ms  
      http_reqs......................: 3304    81.791011/s  
      iteration_duration.............: avg=534.28ms min=513ms   med=528.22ms max=690.41ms p(90)=557.91ms p(95)=572.64ms  
      iterations.....................: 3304    81.791011/s  
      vus............................: 3       min=3  max=50  
      vus_max........................: 50      min=50 max=50  

> The crucial attribute to examine is http_req_duration.  
  This attribute indicates total time for the request (including time to send and receive response from     
  Ciphertrust Manager's EKM service).

Refer to the following links for details: 
- https://k6.io/docs/using-k6  
- https://k6.io/docs/using-k6/metrics/  


