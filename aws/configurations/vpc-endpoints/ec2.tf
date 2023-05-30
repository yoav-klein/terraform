
locals {
    amis = {
        ubuntu = "ami-0f1bae6c3bedcc3b5"
        amazon = "ami-0715c1897453cabd1"
    }
}


######### Security groups ##############

resource "aws_security_group" "bastion" {
  name = "bastion"
  vpc_id = module.vpc.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
   
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }  
}

resource "aws_security_group" "private" {
  name = "private"
  vpc_id = module.vpc.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    security_groups = [aws_security_group.bastion.id]
  }

}

resource "aws_security_group_rule" "bastion_to_private" {
    type = "egress"
    from_port = 22
    to_port = 22
    protocol = "TCP"
    security_group_id = aws_security_group.bastion.id
    source_security_group_id = aws_security_group.private.id
}

resource "aws_security_group_rule" "private_to_vpc_endpoint" {
    type = "egress"
    description = "Outbound to VPC endpoint"
    from_port = 443
    to_port = 443
    protocol = "TCP"
    security_group_id = aws_security_group.private.id
    source_security_group_id = aws_security_group.endpoint.id
}

############ Instance profile for the private instance ##############

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "private" {
  name               = "private"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "rds_access" {
    role = aws_iam_role.private.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
}

resource "aws_iam_instance_profile" "private" {
  name = "private"
  role = aws_iam_role.private.name
}



############### EC2 instances #######################

resource "aws_key_pair" "this" {
  key_name   = "keypair"
  public_key = file("${path.root}/aws.pub")
}


resource "aws_instance" "bastion" {
  ami                  = local.amis["ubuntu"]
  key_name             = aws_key_pair.this.key_name
  instance_type        = "t2.small"
  vpc_security_group_ids  = [aws_security_group.bastion.id]
  subnet_id = module.vpc.public_subnet_ids[0]

  tags = {
    Name = "bastion"
  }

  provisioner "file" {
      source = "aws"
      destination = "/home/ubuntu/aws"
  }

  provisioner "file" {
     content = "${aws_instance.private.private_dns}"
     destination = "/home/ubuntu/private.txt"
  }

}

resource "aws_instance" "private" {
    ami                  = local.amis["amazon"]
    key_name             = aws_key_pair.this.key_name
    instance_type        = "t2.small"
    iam_instance_profile = aws_iam_instance_profile.private.id
    vpc_security_group_ids  = [aws_security_group.private.id, aws_security_group.ec2_rds.id]
    subnet_id = module.vpc.private_subnet_ids[0]
    user_data = <<EOF
#!/bin/bash
sudo yum install -y mysql
EOF

    tags = {
        Name = "private"
      }

}


############ outputs ################


output "bastion_dns" {
    description = "Public DNS of EC2"
    value = aws_instance.bastion.public_dns
}

output "private_dns" {
    description = "Private DNS of the private instance"
    value = aws_instance.private.private_dns
}
