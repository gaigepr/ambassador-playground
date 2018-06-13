#!/bin/bash -e

# install ambassador and an http-echo service reachable at localhost:80
NAMESPACE="ambassador-playground"
kubectl create ns $NAMESPACE
kustomize build ./k8s/ambassador/overlays/docker-for-desktop | kubectl -n $NAMESPACE apply -f -
kustomize build ./k8s/http-echo/base | kubectl -n $NAMESPACE apply -f -
