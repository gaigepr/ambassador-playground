#!/bin/bash -e
kubectl -n default delete --ignore-not-found pod --all
kubectl -n default delete --ignore-not-found svc --all
kubectl delete --ignore-not-found ns ambassador-playground istio-system
