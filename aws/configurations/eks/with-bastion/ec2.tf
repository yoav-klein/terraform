

locals {
    amis = {
        ubuntu = "ami-0f1bae6c3bedcc3b5"
    }
}


module "bastion" {
    source = "../../../modules/ec2"

    name = "bastion"    
    ami = local.amis["ubuntu"]
    pub_key_path="${path.module}/aws.pub"
    use_default_sg = true
    instance_count = 1
    default_vpc = false
    vpc_id = module.vpc.vpc_id
    subnet_ids = [ module.vpc.public_subnet_ids[0] ]
}

output "ec2_domain" {
    value = module.bastion.public_dns
}
