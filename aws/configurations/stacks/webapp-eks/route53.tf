


data "aws_route53_zone" "public" {
    name = "yoav-klein.com"
    private_zone = false
}


resource "aws_route53_record" "my_website" {
  zone_id = data.aws_route53_zone.public.zone_id
  name    = "www2.yoav-klein.com"
  type    = "A"
  
  alias {
    name = data.aws_lb.myapp.dns_name
    zone_id = data.aws_lb.myapp.zone_id
    evaluate_target_health = false
  }

}

output "website_url" {
    value = aws_route53_record.my_website.fqdn
}

