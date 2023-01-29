

terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 4.16"
        }
    }
}

provider "aws" {}



module "ec2" {
    source = "../../modules/ec2"
    name = "aurora-test"    
    pub_key_path="${path.module}/aws.pub"
    instance_count = 1
    default_vpc = true
    
}
