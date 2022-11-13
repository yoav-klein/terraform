

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
}
