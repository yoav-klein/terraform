
# Configure the AWS provider
provider "aws" {
  region = "us-east-1" # Change the region as needed
}


# Create a security group to allow WinRM
resource "aws_security_group" "winrm_sg" {
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 5985
    to_port     = 5985
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5986
    to_port     = 5986
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

   
  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "winrm_sg"
  }
}

# Create a key pair
resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "generated_key" {
  key_name   = "generated-key"
  public_key = tls_private_key.example.public_key_openssh
}

# Save the private key to a file
resource "local_file" "private_key" {
  content  = tls_private_key.example.private_key_pem
  filename = "${path.module}/generated-key.pem"
}

locals {
    names = toset(["client", "server"])
}

# Create an EC2 instance
resource "aws_instance" "windows_server" {
  for_each = local.names
  ami                    = "ami-0069eac59d05ae12b" # Windows Server 2022 AMI ID, ensure this is correct or find the appropriate one for your region
  instance_type          = "t2.medium"
  subnet_id              = module.vpc.public_subnet_ids[0]
  vpc_security_group_ids       = [aws_security_group.winrm_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "winrm-${each.key}"
  }

  # User data script to enable WinRM (HTTP and HTTPS)
#  user_data = <<-EOF
#    <powershell>
#    winrm quickconfig -q
#    winrm set winrm/config/winrs @{MaxMemoryPerShellMB="1024"}
#    winrm set winrm/config @{MaxTimeoutms="1800000"}
#    winrm set winrm/config/service @{AllowUnencrypted="true"}
#    winrm set winrm/config/service/auth @{Basic="true"}
#    </powershell>
#  EOF

  key_name = aws_key_pair.generated_key.key_name # Replace with your key pair name
}

# Output the instance's public IP
#output "instance_public_ip" {
#  value = aws_instance.windows_server[*].public_ip
#}

