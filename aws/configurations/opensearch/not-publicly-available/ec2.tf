
#########################################
#  EC2 instance
########################################

module "ec2" {
    name = "bastion"
    source = "../../../modules/ec2"
    instance_type = "t2.micro"
    pub_key_path="${path.module}/aws.pub"
    instance_count = 1
    subnet_ids = module.vpc.public_subnet_ids
    default_vpc = false
    use_default_sg = true
    security_group_ids = [aws_security_group.ec2.id]  
    vpc_id = module.vpc.vpc_id
}

output "ec2_dns" {
    description = "Public DNS of EC2"
    value = module.ec2.public_dns
}
