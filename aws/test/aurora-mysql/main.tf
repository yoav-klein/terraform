

data "aws_vpc" "default" {
    default = true
}

data "aws_subnets" "default" {
    filter {
        name = "vpc-id"
        values = [data.aws_vpc.default.id]
    }
}

module "mysql-cluster" {
    source = "../../modules/aurora-mysql"
    
    name = "my-cluster"
    
    vpc_id = data.aws_vpc.default.id
    subnet_ids = data.aws_subnets.default.ids
    username = "admin"
    password = "yoavklein3"
    
}

output "cluster_endpoint" {
    description = "Cluster endpoint"
    value = module.mysql-cluster.cluster_endpoint
}

output "reader_endpoint" {
    description = "Reader endpoint"
    value = module.mysql-cluster.reader_endpoint
}
