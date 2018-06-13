# Introduction
This repo demonstrates how to setup various services in a kubernetes namespace with an [ambassador](https://getambassador.io) gateway.

# Setup istio first
I follow [this particular](https://istio.io/docs/setup/kubernetes/helm-install/#option-1-install-with-helm-via-helm-template) way of installation and added the yaml to git.

Next I deployed [this demo program](https://istio.io/docs/guides/bookinfo/).

# Deploy & Test
```
$ cat deploy-all.sh 
#!/bin/bash -e

# install and test istio & the demo bookinfo app
kubectl create ns istio-system
kubctl apply -f k8s/istio.yaml
kubectl apply -f k8s/bookinfo.yaml
# install ambassador and an http-echo service reachable at localhost:80
NAMESPACE="ambassador-playground"
kubectl create ns $NAMESPACE
kustomize build ./k8s/ambassador/overlays/docker-for-desktop | kubectl -n $NAMESPACE apply -f -
kustomize build ./k8s/http-echo/base | kubectl -n $NAMESPACE apply -f -

```

```
$ bash deploy-all.sh ambassador-playground
```
Now let's take a look at the service that is declared for this http-echo service.
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

If everything worked out, ambassador will be available on `localhost:80` so we can curl services.
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