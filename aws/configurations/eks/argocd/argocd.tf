
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"

  version    = "6.7.3"
  upgrade_install = true
  namespace = "argocd"
  create_namespace = true

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

resource "time_sleep" "wait_30_seconds" {
  depends_on = [ helm_release.aws_load_balancer_controller ]

  create_duration = "30s"
}

resource "argocd_repository_credentials" "my_org" {
  url = "https://github.com/deployment-demo/"
  username = "yoav"
  password = "yoavklein3"

  depends_on = [ time_sleep.wait_30_seconds ]

}
