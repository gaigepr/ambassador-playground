# Introduction
This repo demonstrates how to setup various services in a kubernetes namespace with an [ambassador](https://getambassador.io) gateway.

# Deploy & Test
```
$ kubectl create ns ambassador-playground
```

```
$ cat deploy-all.sh 
#!/bin/bash -e
NAMESPACE=$1
kustomize build ./k8s/ambassador/overlays/docker-for-desktop | kubectl -n $NAMESPACE apply -f -
kustomize build ./k8s/http-echo/base | kubectl -n $NAMESPACE apply -f -
```

```
$ bash deploy-all.sh ambassador-playground
service "g-ambassador" created
service "g-ambassador-admin" created
serviceaccount "g-ambassador" created
deployment "g-ambassador" created
clusterrole "g-ambassador" configured
clusterrolebinding "g-ambassador" configured
service "http-echo" created
deployment "http-echo" created
```

Now let's take a look at the service that is declared for this echo service.
```
---
apiVersion: v1
kind: Service
metadata:
  labels:
    service: http-echo
  name: http-echo
  annotations:
    getambassador.io/config: |
      ---
      apiVersion: ambassador/v0
      kind: Mapping
      name: http-echo_mapping
      grpc: false
      prefix: /echo
      rewrite: /
      service: http-echo
spec:
  type: ClusterIP
  ports:
  - port: 80
    name: http-echo
    targetPort: http
  selector:
    service: http-echo
```

If everything worked out, ambassador will be available on `localhost:80` (without a `port-forward` too) so we can curl services easily!
```
$ cat http-echo-test.sh
#!/bin/bash -e
curl -X POST -d "Howdy, ya'll." localhost:80/echo
```

```
$ bash http-echo-test.sh
{
  "path": "/",
  "headers": {
    "host": "localhost",
    "user-agent": "curl/7.54.0",
    "accept": "*/*",
    "content-length": "13",
    "content-type": "application/x-www-form-urlencoded",
    "x-forwarded-proto": "http",
    "x-request-id": "5356a81f-d050-416c-98f7-72205d21677e",
    "x-envoy-expected-rq-timeout-ms": "3000",
    "x-envoy-original-path": "/echo"
  },
  "method": "POST",
  "body": "Howdy, ya'll.",
  "fresh": false,
  "hostname": "localhost",
  "ip": "::ffff:10.1.5.218",
  "ips": [],
  "protocol": "http",
  "query": {},
  "subdomains": [],
  "xhr": false,
  "os": {
    "hostname": "http-echo-7964478884-54lts"
  }
}
```