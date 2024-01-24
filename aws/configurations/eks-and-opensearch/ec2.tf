
resource "aws_security_group" "jump_server" {
  name        = "Windows jump server"
  description = "Allow RDP inbound and all outbound"
  vpc_id      = module.vpc.vpc_id
  
  ingress {
    description = "RDP"
    from_port = 3389
    to_port = 3389
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound"
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}

resource "aws_key_pair" "this" {
  key_name   = "jump-server-keypair"
  public_key = file("aws.pub")
}


resource "aws_instance" "jump_server" {
  ami           = "ami-00d990e7e5ece7974"
  instance_type = "t2.small"
  vpc_security_group_ids =  [aws_security_group.jump_server.id]
  key_name = "test"
  subnet_id = module.vpc.public_subnet_ids[0]
  tags = {
    Name = "Jump Server"
  }
}
