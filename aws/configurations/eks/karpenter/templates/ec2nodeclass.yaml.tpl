apiVersion: karpenter.k8s.aws/v1
kind: EC2NodeClass
metadata:
  name: default
spec:
  role: "${node_role_name}"
  amiFamily: AL2023
  amiSelectorTerms:
    - id: "${ami_id}"
  subnetSelectorTerms:
    - tags:
        karpenter.sh/discovery: "${cluster_name}"
  securityGroupSelectorTerms:
    - id: ${cluster_security_group}

