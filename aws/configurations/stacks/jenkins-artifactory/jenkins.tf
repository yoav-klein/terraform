


resource "aws_instance" "jenkins" {
  ami                  = "ami-053b0d53c279acc90" # 'Ubuntu 22.04'
  key_name             = aws_key_pair.key_pair.key_name
  instance_type        = "t2.medium"
  vpc_security_group_ids = [ aws_security_group.this.id ]
  subnet_id = module.vpc.public_subnet_ids[0]
    user_data = <<EOF
#!/bin/bash
curl -L get.docker.com | bash
usermod -aG docker ubuntu
docker run --name jenkins --restart=on-failure --detach \
  --env DOCKER_CERT_PATH=/certs/client --env DOCKER_TLS_VERIFY=1 \
  --publish 8080:8080 --publish 50000:50000 \
  --volume jenkins-data:/var/jenkins_home \
  --volume jenkins-docker-certs:/certs/client:ro \
  jenkins/jenkins:2.452.1-jdk17

EOF
  tags = {
    Name = "Jenkins"
  }

}

output "jenkins_public_domain" {
    description = "Jenkins domain"
    value = aws_instance.jenkins.public_dns
}

