

 
resource "aws_wafv2_web_acl" "this" {
   name = "test_webacl"
 
   default_action {
     allow {}
   }
 
   # spceifies whether this is for CloudFront or regional resources
   # valid values are CLOUDFRONT or REGIONAL
   scope = "CLOUDFRONT"
 
   rule {
     name = "BlockIsrael"
     action {
       block {}
     }
     priority = 1
     statement {
        geo_match_statement {
            country_codes = ["IL", "IE"]
        }
     }
     visibility_config {
       cloudwatch_metrics_enabled = true
       metric_name                = "BlockMyIP"
       sampled_requests_enabled   = true
     }
   }
 
   visibility_config {
     # whether the associated resource sends metrics to CloudWatch
     cloudwatch_metrics_enabled = true
     metric_name                = "MyWafMetric"
     sampled_requests_enabled   = true
   }
 
 
 }
 

resource "aws_cloudwatch_log_group" "this" {
    name = "aws-waf-logs-test"
}

resource "aws_wafv2_web_acl_logging_configuration" "this" {
    log_destination_configs = [aws_cloudwatch_log_group.this.arn]
    resource_arn = aws_wafv2_web_acl.this.arn
}



