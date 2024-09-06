
######### CloudWatch agent with Prometheus Support ##########



# we create the Namespace and ServiceAccount separately
# in order to attach the service account to the role

resource "kubectl_manifest" "cloudwatch_namespace" {
    yaml_body = <<YAML
apiVersion: v1
kind: Namespace
metadata:
  name: amazon-cloudwatch
   
YAML

}

resource "kubectl_manifest" "cwagent_prometheus_sa" {
    depends_on = [ kubectl_manifest.cloudwatch_namespace ]
    yaml_body = <<YAML
apiVersion: v1
kind: ServiceAccount
metadata:
  name: cwagent-prometheus
  namespace: amazon-cloudwatch
  annotations:
     eks.amazonaws.com/role-arn: ${aws_iam_role.cloudwatch_agent.arn}
   
YAML

}

## After the ServiceAccount is deployed, deploy the CloudWatch Agent with Prometheus support

data "kubectl_file_documents" "cwprometheus" {
    content = file("${path.root}/kubernetes-yamls/cwagent-prometheus.yaml")
}

resource "kubectl_manifest" "cwprometheus" {
    depends_on = [ kubectl_manifest.cwagent_prometheus_sa ]
    
    count     = length(data.kubectl_file_documents.cwprometheus.documents)
    yaml_body = element(data.kubectl_file_documents.cwprometheus.documents, count.index)
}


