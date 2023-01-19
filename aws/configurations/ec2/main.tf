

terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 4.16"
        }
    }
}

provider "aws" {}



module "myInstance" {
    source = "../../modules/ec2"
    
    pub_key_path="${path.module}/aws.pub"
    instance_count = 1
    subnet_ids = ["subnet-065ebc6784a32b2b4", "subnet-05c71c3c7b9e6b77e"]
    default_vpc = false
    vpc_id = "vpc-0a5688acdda9cbb8e"
}
