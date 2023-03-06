

terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 4.16"
        }
    }
}

provider "aws" {}


######################################################
#
#   Use default VPC
#
######################################################

module "my-instance" {
    name = "test-user-data"
    source = "../../modules/ec2"
    instance_type = "t2.micro"
    pub_key_path="${path.module}/aws.pub"
    instance_count = 1
    default_vpc = true
    user_data = <<EOF
#!/bin/bash
echo "HEllo mannn" > /home/ec2-user/file
sudo yum install -y mysql
EOF

}

output "pub_dns" {
    value = module.my-instance.public_dns
    description = "Public DNS"
}
