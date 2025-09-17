#!/bin/bash

KARPENTER_VERSION=1.7.0
KARPENTER_NAMESPACE=karpenter
CLUSTER_NAME=$(terraform output -raw cluster_name)
SERVICE_ACCOUNT_ROLE_ARN=$(terraform output -raw karpenter_role_arn)


helm upgrade --install karpenter oci://public.ecr.aws/karpenter/karpenter --version "${KARPENTER_VERSION}" --namespace "${KARPENTER_NAMESPACE}" --create-namespace \
  --set "serviceAccount.annotations.eks\.amazonaws\.com/role-arn=${SERVICE_ACCOUNT_ROLE_ARN}" \
  --set "settings.clusterName=${CLUSTER_NAME}" \
  --set "settings.interruptionQueue=${CLUSTER_NAME}" \
  --set controller.resources.requests.cpu=200m \
  --set controller.resources.requests.memory=512Mi \
  --set controller.resources.limits.cpu=200m \
  --set controller.resources.limits.memory=1Gi \
  --wait
