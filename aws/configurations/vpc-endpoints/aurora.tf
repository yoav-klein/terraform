

module "mysql_cluster" {
    source = "../../modules/aurora-mysql"
    
    name = "example"
    num_instances = 3
    engine_version = "5.7.mysql_aurora.2.11.2"
    vpc_id = module.vpc.vpc_id
    subnet_ids = module.vpc.private_subnet_ids
    security_group_ids = [aws_security_group.rds_ec2.id]
    username = "admin"
    password = "yoavklein3"
    
}

output "cluster_endpoint" {
    description = "Cluster endpoint"
    value = module.mysql_cluster.cluster_endpoint
}

output "reader_endpoint" {
    description = "Reader endpoint"
    value = module.mysql_cluster.reader_endpoint
}
