
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
  
  alias {
    name = aws_lb.this.dns_name
    zone_id = aws_lb.this.zone_id
    evaluate_target_health = false
  }

}

output "nameservers" {
    description = "Name servers"
    value = aws_route53_zone.public_zone.name_servers
}
