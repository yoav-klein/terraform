
###############################################################################
# Data sources for ${AWS::Partition}, ${AWS::Region}, ${AWS::AccountId}
###############################################################################
data "aws_partition" "current" {}
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}


###############################################################################
# Create the policy and role
###############################################################################

# the Karpenter Controller policy
data "template_file" "karpenter_controller_policy" {
    template = file("${path.root}/templates/karpenter-controller-policy.json.tpl")
    vars = {
        account_id = data.aws_caller_identity.current.account_id
        cluster_name = aws_eks_cluster.this.name
        region = data.aws_region.current.name
        node_role_arn = aws_iam_role.node_role.arn
        karpenter_interruption_queue_arn = aws_sqs_queue.interruption_queue.arn
    }
}

resource "aws_iam_policy" "karpenter_controller" {
  name   = "KarpenterControllerPolicy-${aws_eks_cluster.this.name}"
  policy = data.template_file.karpenter_controller_policy.rendered
}


# The trust policy of the role
data "aws_iam_policy_document" "assume_role_document_karpenter_controller" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.this.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:karpenter:karpenter"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.this.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "karpenter_controller" {
    name = "KarpenterRole-${aws_eks_cluster.this.name}"
    assume_role_policy = data.aws_iam_policy_document.assume_role_document_karpenter_controller.json
}

resource "aws_iam_role_policy_attachment" "karpenter_role_policy_attachment" {
  policy_arn = aws_iam_policy.karpenter_controller.arn
  role       = aws_iam_role.karpenter_controller.name
}


###############################################################################
#   Karpenter Helm chart
###############################################################################

resource "helm_release" "karpenter" {
    name = "karpenter"
    repository = "oci://public.ecr.aws/karpenter"
    chart = "karpenter"
    version = local.karpenter_version
    namespace = "karpenter"
    create_namespace = true
    set = [
        {
            name  = "settings.clusterName"
            value = aws_eks_cluster.this.name
        },
        {
            name  = "settings.interruptionQueue"
            value = aws_eks_cluster.this.name
        },
        {
            name = "controller.resources.requests.cpu"
            value = "200m"
        },
        {
            name = "controller.resources.requests.memory"
            value = "512Mi"
        },
        {
            name = "controller.resources.limits.cpu"
            value = 1
        },
        {
            name = "controller.resources.limits.memory"
            value = "1Gi"
        },
        {
            name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
            value = aws_iam_role.karpenter_controller.arn
        },

    ]
    depends_on = [aws_eks_cluster.this] 
}

###############################################################################
# Interruption SQS queue
###############################################################################

resource "aws_sqs_queue" "interruption_queue" {
  name                       = "KarpenterInterruption"
  delay_seconds              = 30
  visibility_timeout_seconds = 60
  max_message_size           = 2048
  message_retention_seconds  = 300
  receive_wait_time_seconds  = 10 # long polling

  policy = <<POLICY
  {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "EC2InterruptionPolicy",
            "Effect": "Allow",
            "Principal": { "Service": [ "events.amazonaws.com", "sqs.amazonaws.com" ] },
            "Action": "sqs:SendMessage",
            "Resource": "arn:aws:sqs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:KarpenterInterruption"
        }
    ]
  }
POLICY
}


# EventBridge rules

resource "aws_cloudwatch_event_rule" "scheduled_change_rule" {
  name        = "ScheduledChangeRule"
  description = "Scheduled change rule"

  event_pattern = jsonencode({
    detail-type = [ "AWS Health Event" ]
    source = [ "aws.ec2" ]
  })
}

resource "aws_cloudwatch_event_target" "scheduled_change_rule" {
  rule      = aws_cloudwatch_event_rule.scheduled_change_rule.name
  arn       = aws_sqs_queue.interruption_queue.arn
}

resource "aws_cloudwatch_event_rule" "spot_interruption_rule" {
  name        = "SpotInterruptionRule"
  description = "Spot interruption rule"

  event_pattern = jsonencode({
    detail-type = [ "EC2 Spot Instance Interruption Warning" ]
    source = [ "aws.ec2" ]
  })
}

resource "aws_cloudwatch_event_target" "spot_interruption_rule" {
  rule      = aws_cloudwatch_event_rule.spot_interruption_rule.name
  arn       = aws_sqs_queue.interruption_queue.arn
}


resource "aws_cloudwatch_event_rule" "rebalance_rule" {
  name        = "RebalanceRule"
  description = "Rebalance rule"

  event_pattern = jsonencode({
    detail-type = [ "EC2 Instance Rebalance Recommendation" ]
    source = [ "aws.ec2" ]
  })
}

resource "aws_cloudwatch_event_target" "rebalance_rule" {
  rule      = aws_cloudwatch_event_rule.rebalance_rule.name
  arn       = aws_sqs_queue.interruption_queue.arn
}

resource "aws_cloudwatch_event_rule" "instance_state_change_rule" {
  name        = "InstanceStateChangeRule"
  description = "Instance state change rule"

  event_pattern = jsonencode({
    detail-type = [ "EC2 Instance State-change Notification" ]
    source = [ "aws.ec2" ]
  })
}

resource "aws_cloudwatch_event_target" "instance_state_change_rule" {
  rule      = aws_cloudwatch_event_rule.instance_state_change_rule.name
  arn       = aws_sqs_queue.interruption_queue.arn
}





###############################################################################
#   NodePool and EC2NodeClass
###############################################################################

data "aws_ssm_parameter" "ami" {
    name = "/aws/service/eks/optimized-ami/${local.kubernetes_version}/amazon-linux-2023/x86_64/standard/recommended/image_id"
}

# Karpenter resources

data "template_file" "ec2nodeclass" {
    template = file("${path.root}/templates/ec2nodeclass.yaml.tpl")
    vars = {
       node_role_name = aws_iam_role.node_role.name
       cluster_name = aws_eks_cluster.this.name
       cluster_security_group = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
       ami_id = data.aws_ssm_parameter.ami.value
    }

}

resource "kubectl_manifest" "ec2nodelcass" {
    yaml_body = data.template_file.ec2nodeclass.rendered
    
    depends_on = [ helm_release.karpenter ]
}

resource "kubectl_manifest" "nodepool" {
    yaml_body = file("${path.root}/templates/nodepool.yaml")
    
    depends_on = [ helm_release.karpenter ]
}
