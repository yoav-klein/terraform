
output "cluster" {
    value = resource.aws_eks_cluster.this
}

output "cluster_security_group" {
    value = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}

output "openid_connect_provider" {
    value = aws_iam_openid_connect_provider.this
}
