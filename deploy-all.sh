#!/bin/bash -e
NAMESPACE=$1
kustomize build ./k8s/ambassador/overlays/docker-for-desktop | kubectl -n $NAMESPACE apply -f -
kustomize build ./k8s/http-echo/base | kubectl -n $NAMESPACE apply -f -
