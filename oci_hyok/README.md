About this package

This package contains files required to test Ciphertrust Manager's OCI HYOK 
service performance. Run the script in this repository through k6 script to 
collect OCI HYOK performance numbers.

Recommendation

For best performance, it is recommended to have following:

* Ciphertrust Manager configuration of >= 4CPU, 16GB memory.
* Ciphertrust Manager instance  along with Luna HSM hosted in same 
  region/zone as the client machine where k6 is run.
* For getting closest results to your environment, deploy client in same 
  region as your CM and Luna.

Prerequisites
* This tool is supported only with Ciphertrust Manager version >= 2.8.0.
* Setup Linux system with Ubuntu with bash shell support. Other Linux 
  distributions also might work. We have tested with Ubuntu 20.04.3 LTS.

* Install k6 client by referring to Ubuntu installation steps available at: 
  https://k6.io/docs/getting-started/installation/

Steps to run k6 client to measure OCI HYOK encrypt performance:
1. Edit the oci_env file and modify the values for following params
   * CM_URL= CipherTrust Manager IP Address
   * IDP_ID= OCI IDP Id
   * VAULT_ID= OCI External VAULT Id
   * HYOK_KEY_ID= OCI HYOK key Id
   * IDP_ACCESS_ID= OCI Issuer Access Id
   * IDP_SECRET_KEY= OCI Issuer Access Secret
2. Run command `source oci_env` to export the environment variables
3. Run the shell script `get_idp_token.sh` to fetch the IDP token and copy the `access_token` to pass it as command line argument in step-4
4. k6 run --stage 5s:70,30s:70,5s:0 oci_hyok_performance.js -e IDP_TOKEN="eyJhbGciOiJSUzI1NiIsInR5cC.IgOiAiSldUIiwia2lkIiA6ICIz.QmI3OUNEOEQ3NkVBZnp..."

Above runs the performance with following configuration:
* Run test for 40 seconds
* Here is the breakup of 40 seconds
  * Rampup virtual users up to 70 in 5 seconds
  * Maintain 70 virtual users for 30 seconds
  * Ramp down to 0 virtual users in 5 seconds
* Send encrypt requests from virtual users during above
* k6 displays the results after the run is complete. Below is the sample output of k6
```
✓ status code
checks.........................: 100.00% ✓ 3304 ✗ 0 
data_received..................: 4.6 MB 115 kB/s 
data_sent......................: 4.3 MB 106 kB/s
http_req_blocked...............: avg=88µs min=1.96µs med=5.34µs max=47.38ms p(90)=7.16µs p(95)=8.45µs
http_req_connecting............: avg=13.46µs min=0s med=0s max=1.1ms p(90)=0s p(95)=0s
http_req_duration..............: avg=33.26ms min=11.94ms med=27.36ms max=189.21ms p(90)=56.68ms p(95)=71.97ms
{ expected_response:true }...: avg=33.26ms min=11.94ms med=27.36ms max=189.21ms p(90)=56.68ms p(95)=71.97ms
http_req_failed................: 0.00% ✓ 0 ✗ 3304
http_req_receiving.............: avg=104.51µs min=28.03µs med=97.56µs max=2.41ms p(90)=140.84µs p(95)=168.01µs
http_req_sending...............: avg=39.76µs min=11.34µs med=35.06µs max=240.49µs p(90)=53.97µs p(95)=73.68µs
http_req_tls_handshaking.......: avg=61.59µs min=0s med=0s max=26.89ms p(90)=0s p(95)=0s
http_req_waiting...............: avg=33.11ms min=11.78ms med=27.21ms max=188.97ms p(90)=56.55ms p(95)=71.8ms
http_reqs......................: 3304 81.791011/s
iteration_duration.............: avg=534.28ms min=513ms med=528.22ms max=690.41ms p(90)=557.91ms p(95)=572.64ms
iterations.....................: 3304 81.791011/s
vus............................: 3 min=3 max=50
vus_max........................: 50 min=50 max=50
```
The crucial attribute to examine is http_req_duration.
This attribute indicates total time for the request (including time to send and receive response from
Ciphertrust Manager's OCI HYOK service).

Refer to the following links for details:
https://k6.io/docs/using-k6
https://k6.io/docs/using-k6/metrics/