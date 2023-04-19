

data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

resource "aws_wafv2_ip_set" "this" {
  name               = "MyIP"
  description        = "My own IP"
  scope              = "CLOUDFRONT"
  ip_address_version = "IPV4"
  addresses          = ["${chomp(data.http.myip.response_body)}/32"]

}

resource "aws_wafv2_web_acl" "this" {
  name = "test_webacl"

  default_action {
    allow {}
  }

  # spceifies whether this is for CloudFront or regional resources
  # valid values are CLOUDFRONT or REGIONAL
  scope = "CLOUDFRONT"

  rule {
    name = "BlockIP"
    action {
      block {}
    }
    priority = 1

    statement {
      and_statement {
        statement {
          ip_set_reference_statement {
            arn = aws_wafv2_ip_set.this.arn
          }
        }
        statement {
          byte_match_statement {
            field_to_match {
              headers {
                match_pattern {
                  included_headers = ["X-test"]
                }
                match_scope       = "VALUE"
                oversize_handling = "CONTINUE"

              }
            }
            positional_constraint = "EXACTLY"
            search_string         = "kuku"
            text_transformation {
              priority = 0
              type     = "NONE"
            }
          }
        }
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "BlockRule"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    # whether the associated resource sends metrics to CloudWatch
    cloudwatch_metrics_enabled = true
    metric_name                = "MyWaf"
    sampled_requests_enabled   = true
  }


}


