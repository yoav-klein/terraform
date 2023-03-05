
output "cluster_endpoint" {
    description = "Cluster endpoint"
    value = aws_rds_cluster.this.endpoint
}

output "reader_endpoint" {
    description = "Reader endpoint"
    value = aws_rds_cluster.this.reader_endpoint
}
