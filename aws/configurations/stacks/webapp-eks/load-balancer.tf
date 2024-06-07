## istio
data "aws_lb" "myapp" {
  tags = {
    "elbv2.k8s.aws/cluster" = local.cluster_name
    "ingress.k8s.aws/stack" = "default/generator"
  }

  depends_on = [ kubectl_manifest.myapp ]
}

# Install ingress public
resource "kubectl_manifest" "myapp" {
  yaml_body = templatefile("${path.root}/demo-alb/ingress.yaml", {
  certificate_arn = aws_acm_certificate.cert.arn })


    #cert_arn     = data.aws_acm_certificate.issued.arn
    #waf_acl_arn  = aws_wafv2_web_acl.istio.arn
    #external_url = local.route53_domain_name})

}
