
resource "aws_security_group" "opensearch" {
    name = "opensearch"
    vpc_id = module.vpc.vpc_id
}
resource "aws_security_group_rule" "opensearch_eks" {
    type = "ingress"
    description = "Allow EC2 ingress"
    from_port = 443
    to_port = 443
    protocol = "TCP"
    source_security_group_id = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
    security_group_id = aws_security_group.opensearch.id
}


