#!/bin/bash -e
kubectl delete --ignore-not-found ns bookinfo ambassador-playground istio-system
