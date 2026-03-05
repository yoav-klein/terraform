
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"

  version    = "6.7.3"

  create_namespace = true

  values = [
    yamlencode({
      server = {
        service = {
          type = "LoadBalancer"
        }
      }
    })
  ]
}

resource "argocd_repository_credentials" "my_org" {
  url = "https://github.com/deployment-demo/"
  username = "yoav"
  password = "yoavklein3"
}
