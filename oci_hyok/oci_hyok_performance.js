import http from 'k6/http';
import { check, sleep } from 'k6';
import { Counter, Rate } from 'k6/metrics';
import crypto from 'k6/crypto';

let ErrorCount = new Counter("errors");

export let errorRate = new Rate('error_rate');

// To disable the certificate verification
export const options = {
    insecureSkipTLSVerify: true,
}

export default function () {

  if (typeof(`${__ENV.IDP_TOKEN}`) == "undefined"){
    console.log('Missing required IDP token for the encrypt request');
    return false;
  }
    var mode = "AES_GCM"
    var plain_text = "YWJjZGVmZ2hpamtsbW5vcHFyc3R1dnd4eXphYmNkZWY="

    var payload = `{
        "plaintext": "${plain_text}",
        "mode": "${mode}"
    }`
    var IdpToken = `${__ENV.IDP_TOKEN}`;
    var url = `https://${__ENV.CM_URL}/api/v1/cckm/oci/ekm/v1/vaults/${__ENV.VAULT_ID}/keys/${__ENV.HYOK_KEY_ID}/encrypt`
    var params = {
        headers: {
            'Content-Type': 'application/json',
            'opc-request-id':"abcd",
            'Authorization': 'Bearer ' + IdpToken
        },
    }
    let res = http.post(url, payload, params)
    const result = check(res, {
        'status code': (r) => r.status === 200,
    });
    errorRate.add(!result)

};


