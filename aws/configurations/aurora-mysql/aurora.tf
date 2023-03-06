

module "mysql_cluster" {
    source = "../../modules/aurora-mysql"
    
    name = "example"
    
    vpc_id = module.vpc.vpc_id
    subnet_ids = module.vpc.private_subnet_ids
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
