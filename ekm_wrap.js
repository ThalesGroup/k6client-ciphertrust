import http from 'k6/http';
import { check, fail, sleep } from 'k6';
import { Counter, Rate } from 'k6/metrics';

let ErrorCount = new Counter("errors");
let ErrorRate = new Rate("error_rate");

export let options = {
	thresholds: {
		'fatal_errors': [{threshold:'count<1', abortOnFail: true}]
	}
};
const abortMetric = new Counter('fatal_errors');

export default function () {
  var endpointURL = `${__ENV.ENDPOINT_URL}`;
  if (endpointURL === "undefined" || endpointURL === null || endpointURL === "") {
   abortMetric.add(1);
   sleep(1);
   fail(`ENDPOINT_URL has to be specified. (Currently set to '${endpointURL}') Eg: https://ekm.thales.com/api/v1/cckm/ekm/endpoints/77a62bf2-a6a1-41a8-8da8-b6994bb88012`)
  }

  var payload = JSON.stringify({
    "plaintext": "test", 
    "additionalContext": 
    {
        "accessReasonContext": 
        {
            "reason": "CUSTOMER_INITIATED_SUPPORT"
        }, 
	"RelativeResourceName":"projects/test-ekm/locations/us/keyRings/n1-key-ring/cryptoKeys/kylo-nv-2/cryptoKeyVersions/16",
        "is_key_health_check": null
    }
  });

  var googleToken = 'Bearer ' + `${__ENV.G_TOKEN}`;
  var params = {
    headers: {
      'Content-Type': 'application/json',
      'Authorization': googleToken
    },
  };
    let response = http.post(endpointURL + ":wrap", payload, params);
/*
    // Add a env variable that can be used to toggle this logging.
    console.log("Response Duration: ", String(response.timings.duration));
    console.log("Response Time    : ", String(response.timings.receiving));
    console.log("Sending Time     : ", String(response.timings.sending));
    console.log("Waiting Time     : ", String(response.timings.waiting));
    console.log("wrapped data     : ", String(response.body)); 
*/


    const success = check(response, {
        //'response time': (r) => r.timings.duration <= 150,
        'status code': (r) => r.status === 200,
    });
    if (!success) { 
	ErrorCount.add(1);    
        ErrorRate.add(true);
    }	    
    
    sleep(0.5);
}


