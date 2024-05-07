terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 4.50"
        }
    }
}

provider "aws" {}

resource "aws_route53_zone" "public_zone" {
  name = "yoav-klein.com"
  tags = {
    Environment = "Production"
  }
}


resource "aws_route53_record" "my_website" {
  zone_id = aws_route53_zone.public_zone.zone_id
  name    = "www.yoav-klein.com"
  type    = "A"
  ttl     = "30"
  records = ["1.2.3.4"]
}

output "nameservers" {
    description = "Name servers"
    value = aws_route53_zone.public_zone.name_servers
}
