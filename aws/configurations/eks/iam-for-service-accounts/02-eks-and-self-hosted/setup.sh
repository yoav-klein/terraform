#!/bin/bash

# install microk8s
sudo snap install microk8s --classic --channel=1.29

sudo usermod -a -G microk8s $USER
sudo chown -f -R $USER ~/.kube

sudo snap alias microk8s.kubectl kubectl

# install cert-manager
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.14.2/cert-manager.yaml


# install pod-identity-webhook
sudo apt-get install -y  make
git clone https://github.com/aws/amazon-eks-pod-identity-webhook.git
cd amazon-eks-pod-identity-webhook
make cluster-up IMAGE=amazon/amazon-eks-pod-identity-webhook:latest



