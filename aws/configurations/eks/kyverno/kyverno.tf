
resource "helm_release" "kyverno" {
  name             = "kyverno"
  namespace        = "kyverno"
  create_namespace = true

  repository = "https://kyverno.github.io/kyverno/"
  chart      = "kyverno"
  version    = "3.8.1"
}
