

data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

# resource "aws_wafv2_ip_set" "this" {
#   name               = "MyIP"
#   description        = "My own IP"
#   scope              = "CLOUDFRONT"
#   ip_address_version = "IPV4"
#   addresses          = ["${chomp(data.http.myip.response_body)}/32"]
# 
# }
# 
# resource "aws_wafv2_web_acl" "this" {
#   name = "test_webacl"
# 
#   default_action {
#     allow {}
#   }
# 
#   # spceifies whether this is for CloudFront or regional resources
#   # valid values are CLOUDFRONT or REGIONAL
#   scope = "CLOUDFRONT"
# 
#   rule {
#     name = "BlockMyIP"
#     action {
#       block {}
#     }
#     priority = 1
#     statement {
#       ip_set_reference_statement {
#         arn = aws_wafv2_ip_set.this.arn
#       }
#     }
#     visibility_config {
#       cloudwatch_metrics_enabled = true
#       metric_name                = "BlockMyIP"
#       sampled_requests_enabled   = true
#     }
#   }
# 
#   visibility_config {
#     # whether the associated resource sends metrics to CloudWatch
#     cloudwatch_metrics_enabled = true
#     metric_name                = "MyWafMetric"
#     sampled_requests_enabled   = true
#   }
# 
# 
# }
# 

