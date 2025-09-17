
output "karpenter_role_arn" {
    value = aws_iam_role.karpenter_controller.arn
}

output "karpenter_role_name" {
    value = aws_iam_role.karpenter_controller.name
}

output "node_role_name" {
    value = aws_iam_role.node_role.name
}


output "cluster_name" {
    value = local.cluster_name
}

output "cluster_security_group" {
    value = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}
