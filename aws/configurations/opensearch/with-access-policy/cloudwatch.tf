

resource "aws_cloudwatch_dashboard" "main" {

  dashboard_name = "OpenSearch-${resource.aws_opensearch_domain.this.domain_name}"

  dashboard_body = <<EOF
{
  "widgets": [
    {
      "type": "metric",
      "x": 0,
      "y": 0,
      "width": 6,
      "height": 6,
      "properties": {
        "metrics": [ 
          [
            "AWS/ES",
            "CPUUtilization",
            "DomainName",
            "${var.domain}",
            "ClientId",
            "${data.aws_caller_identity.current.account_id}"
          ]
        ],
        "period": 300,
        "region": "us-east-1",
        "stat": "Average",
        "title": "CPUUtilization"
      }
    },
    {
      "type": "metric",
      "width": 6,
      "height": 6,
      "properties": {
        "metrics": [ 
          [
            "AWS/ES",
            "IndexingRate",
            "DomainName",
            "${var.domain}",
            "ClientId",
            "${data.aws_caller_identity.current.account_id}"
          ]
        ],
        "period": 300,
        "region": "us-east-1",
        "stat": "Average",
        "title": "IndexingRate"
      }
    },
    {
      "type": "metric",
      "width": 6,
      "height": 6,
      "properties": {
        "metrics": [ 
          [
            "AWS/ES",
            "JVMMemoryPressure",
            "DomainName",
            "${var.domain}",
            "ClientId",
            "${data.aws_caller_identity.current.account_id}"
          ]
        ],
        "period": 300,
        "region": "us-east-1",
        "stat": "Average",
        "title": "JVMMemoryPressure"
      }
    },
    {
      "type": "metric",
      "width": 6,
      "height": 6,
      "properties": {
        "metrics": [ 
          [
            "AWS/ES",
            "FreeStorageSpace",
            "DomainName",
            "${var.domain}",
            "ClientId",
            "${data.aws_caller_identity.current.account_id}"
          ]
        ],
        "period": 300,
        "region": "us-east-1",
        "stat": "Average",
        "title": "FreeStorageSpace"
      }
    },
    {
      "type": "metric",
      "width": 6,
      "height": 6,
      "properties": {
        "metrics": [ 
          [
            "AWS/ES",
            "SearchRate",
            "DomainName",
            "${var.domain}",
            "ClientId",
            "${data.aws_caller_identity.current.account_id}"
          ]
        ],
        "period": 300,
        "region": "us-east-1",
        "stat": "Average",
        "title": "SearchRate"
      }
    },
     {
      "type": "metric",
      "width": 6,
      "height": 6,
      "properties": {
        "metrics": [ 
          [
            "AWS/ES",
            "ClusterUsedSpace",
            "DomainName",
            "${var.domain}",
            "ClientId",
            "${data.aws_caller_identity.current.account_id}"
          ]
        ],
        "period": 300,
        "region": "us-east-1",
        "stat": "Average",
        "title": "ClusterUserSpace"
      }
    }


  ]
}
EOF
}
