

module "ec2" {
    name = "bastion"
    source = "../../modules/ec2"
    instance_type = "t2.micro"
    pub_key_path="${path.module}/aws.pub"
    instance_count = 1
    subnet_ids = module.vpc.public_subnet_ids
    default_vpc = false
    vpc_id = module.vpc.vpc_id
}
