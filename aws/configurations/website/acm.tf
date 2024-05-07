
resource "aws_acm_certificate" "cert" {
  private_key      = file("${path.module}/demo.key")
  certificate_body = file("${path.module}/0000_cert.pem")
  certificate_chain = file("${path.module}/0001_chain.pem")
}
