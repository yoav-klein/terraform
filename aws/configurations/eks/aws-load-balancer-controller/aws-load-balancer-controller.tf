##################################################
# IAM Infrastructure
##################################################

data "http" "aws_load_balancer_controller_iam_policy_document" {
   url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.4.7/docs/install/iam_policy.json"
}

resource "aws_iam_policy" "aws_load_balancer_controller" {
    name = "AWSLoadBalancerControllerIAMPolicy"
    description = "IAM policy for AWS Load Balancer Controller"
    
    policy = data.http.aws_load_balancer_controller_iam_policy_document.response_body
}

data "aws_iam_policy_document" "assume_role_policy" {
    statement {
        actions = ["sts:AssumeRoleWithWebIdentity"] 
        effect = "Allow"
    
        principals {
            type = "Federated"
            identifiers = [aws_iam_openid_connect_provider.this.arn] 
        }

        condition {
            test = "StringEquals"
            variable = "${replace(aws_iam_openid_connect_provider.this.url, "https://", "")}:sub"
            values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
        }
    
        condition {
            test = "StringEquals"
            variable = "${replace(aws_iam_openid_connect_provider.this.url, "https://", "")}:aud"
            values   = ["sts.amazonaws.com"]
        }
    }
}

resource "aws_iam_role" "aws_load_balancer_controller" {
    name = "AmazonEKSLoadBalancerControllerRole"
    assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "aws_load_balancer_controller_role_policy" {
    role = aws_iam_role.aws_load_balancer_controller.name
    policy_arn = aws_iam_policy.aws_load_balancer_controller.arn
}



#####################################################
#
# Insatll manifests in the cluster - cert-manager and 
# the AWS Load Balancer controller controller
#
#####################################################


data "aws_region" "current" {}

resource "null_resource" "update_kubeconfig" {
    triggers = {
        always_run = timestamp()
    }
    
    provisioner "local-exec" {
        command = "aws eks update-kubeconfig --name ${aws_eks_cluster.this.name} --region ${data.aws_region.current.name}"
    }

    depends_on = [aws_eks_cluster.this]
}

resource "time_sleep" "wait_for_update_kubeconfig" {
  depends_on = [null_resource.update_kubeconfig]

  create_duration = "180s"
}



##############################
# cert-manager
##############################

data "kubectl_file_documents" "cert_manager" {
    content = file("manifests/cert-manager.yaml")
}

# need to create the namespace first, since you might have a race condition
resource "kubectl_manifest" "cert_manager_ns" {
    yaml_body = <<YAML
apiVersion: v1
kind: Namespace
metadata:
    name: cert-manager
YAML

    depends_on = [aws_eks_node_group.this] # time_sleep.wait_for_update_kubeconfig]
}

resource "time_sleep" "wait_for_cert_manager_ns" {
  depends_on = [kubectl_manifest.cert_manager_ns]

  create_duration = "60s"
}

resource "kubectl_manifest" "cert_manager" {
    count = length(data.kubectl_file_documents.cert_manager.documents)

    yaml_body = element(data.kubectl_file_documents.cert_manager.documents, count.index)

    depends_on = [time_sleep.wait_for_cert_manager_ns]
}

###############################
# AWS Load Balancer Controller
###############################

data "kubectl_file_documents" "aws_load_balancer_controller" {
    content = file("manifests/aws-load-balancer-controller.yaml")
}

data "kubectl_file_documents" "ingress_class" {
    content = file("manifests/ingclass.yaml")
}


resource "kubectl_manifest" "service_account_for_alb" {
      yaml_body = <<YAML
apiVersion: v1
kind: ServiceAccount
metadata:
  annotations:
    eks.amazonaws.com/role-arn: ${aws_iam_role.aws_load_balancer_controller.arn}
  labels:
    app.kubernetes.io/component: controller
    app.kubernetes.io/name: aws-load-balancer-controller
  name: aws-load-balancer-controller
  namespace: kube-system
YAML
    
    depends_on = [aws_eks_node_group.this, aws_iam_role.aws_load_balancer_controller] #time_sleep.wait_for_update_kubeconfig, aws_iam_role.aws_load_balancer_controller]
}

resource "kubectl_manifest" "aws_load_balancer_controller" {
    count = length(data.kubectl_file_documents.aws_load_balancer_controller.documents)

    yaml_body = element(data.kubectl_file_documents.aws_load_balancer_controller.documents, count.index)

    depends_on = [kubectl_manifest.cert_manager, kubectl_manifest.service_account_for_alb]
}

resource "kubectl_manifest" "ingress_class" {
    count = length(data.kubectl_file_documents.ingress_class.documents)

    yaml_body = element(data.kubectl_file_documents.ingress_class.documents, count.index)

    depends_on = [kubectl_manifest.aws_load_balancer_controller]
}


