
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}


resource "aws_security_group" "default_sg" {
  name = "mySecurityGroup"
  vpc_id = var.default_vpc ?  data.aws_vpc.default.id : var.vpc_id

  ingress {
    description = "ssh connectivity"
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
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

resource "aws_key_pair" "this" {
  key_name   = "myKey"
  public_key = file(var.pub_key_path)
}

resource "aws_instance" "this" {
  count = var.instance_count

  ami                  = "ami-03dbf0c122cb6cf1d" # Amazon Linux AMI
  key_name             = aws_key_pair.this.key_name
  instance_type        = var.instance_type
  vpc_security_group_ids  = var.use_default_sg ? [aws_security_group.default_sg.id] : var.security_group_ids
  subnet_id = var.default_vpc ?  data.aws_subnets.default_subnets.ids[count.index % length(data.aws_subnets.default_subnets)] : var.subnet_ids[count.index % length(var.subnet_ids)]

  tags = {
    Name = "myInstance${count.index}"
  }

}

