
resource "helm_release" "argocd" {
  name       = "argocd1"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"

  version    = "6.7.3"
  #upgrade_install = true
  namespace = "argocd"
  create_namespace = true
  take_ownership = true

  values = [
    yamlencode({
      server = {
        service = {
          type = "LoadBalancer"
          annotations = {
            "service.beta.kubernetes.io/aws-load-balancer-scheme" = "internet-facing"
          }
        }
      }
    })
  ]
}


