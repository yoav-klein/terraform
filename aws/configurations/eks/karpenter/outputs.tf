
output "karpenter_role_arn" {
    value = aws_iam_role.karpenter_controller.arn
}

output "karpenter_role_name" {
    value = aws_iam_role.karpenter_controller.name
}


output "cluster_name" {
    value = local.cluster_name
}
