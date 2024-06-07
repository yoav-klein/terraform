
data "aws_lb" "myapp" {
  tags = {
    "elbv2.k8s.aws/cluster" = local.cluster_name
    "ingress.k8s.aws/stack" = "default/generator"
  }

  depends_on = [ kubectl_manifest.ingress ]
}

# Install ingress public
resource "kubectl_manifest" "ingress" {
  yaml_body = templatefile("${path.root}/k8s-resources/ingress.yaml", {
  certificate_arn = aws_acm_certificate.cert.arn })

}

data "kubectl_file_documents" "application" {
  content = file("${path.root}/k8s-resources/deployment.yaml")
}

resource "kubectl_manifest" "application" {
  count = length(data.kubectl_file_documents.application.documents)

  yaml_body = element(data.kubectl_file_documents.application.documents, count.index)

}

