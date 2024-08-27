
resource "aws_instance" "artifactory" {
  ami                  = "ami-053b0d53c279acc90" # 'Ubuntu 22.04'
  key_name             = aws_key_pair.key_pair.key_name
  instance_type        = "t3.medium"
  vpc_security_group_ids = [ aws_security_group.this.id ]
  subnet_id = module.vpc.public_subnet_ids[0]
  user_data = <<EOF
#!/bin/bash
curl -L get.docker.com | bash
usermod -aG docker ubuntu
JFROG_HOME=/home/ubuntu/jfrog
mkdir -p $JFROG_HOME/artifactory/var/etc
cd $JFROG_HOME/artifactory/var/etc
touch ./system.yaml
chown -R 1030:1030 $JFROG_HOME/artifactory/var
chmod 777 $JFROG_HOME/artifactory/var

echo "docker run --name artifactory -v $JFROG_HOME/artifactory/var/:/var/opt/jfrog/artifactory -d -p 8081:8081 -p 8082:8082 releases-docker.jfrog.io/jfrog/artifactory-oss:7.59.23" > /home/ubuntu/run.sh
chown ubuntu:ubuntu /home/ubuntu/run.sh
chmod +x /home/ubuntu/run.sh

EOF

  tags = {
    Name = "Artifcatory"
  }

}

output "artifactory_public_domain" {
    description = "Artifactory public domain name"
    value = aws_instance.artifactory.public_dns
}

output "artifactory_private_domain" {
    description = "Artifactory private domain"
    value = aws_instance.artifactory.private_dns
}
