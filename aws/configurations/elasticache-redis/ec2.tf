

module "ec2" {
    name = "bastion"
    source = "../../modules/ec2"
    instance_type = "t2.micro"
    pub_key_path="${path.module}/aws.pub"
    ami = "ami-0f1bae6c3bedcc3b5"
    instance_count = 1
    subnet_ids = module.vpc.public_subnet_ids
    default_vpc = false
    use_default_sg = true
    security_group_ids = [aws_security_group.ec2_sg.id]    
    vpc_id = module.vpc.vpc_id
}

output "ec2_dns" {
    description = "Public DNS of EC2"
    value = module.ec2.public_dns
}
