#!/bin/bash

mkdir -p manifests
rm manifests/*

curl -Lo manifests/cert-manager.yaml https://github.com/jetstack/cert-manager/releases/download/v1.5.4/cert-manager.yaml
curl -Lo manifests/ingclass.yaml https://github.com/kubernetes-sigs/aws-load-balancer-controller/releases/download/v2.4.7/v2_4_7_ingclass.yaml

