resource "aws_cloudwatch_dashboard" "main" {

  dashboard_name = "my-dashboard"

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
            "test-domain",
            "ClientId",
            "791437181286"
          ]
        ],
        "period": 300,
        "region": "us-east-1",
        "stat": "Average",
        "title": "OpenSearch Instance CPU"
      }
    },
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
            "IndexingRate",
            "DomainName",
            "test-domain",
            "ClientId",
            "791437181286"
          ]
        ],
        "period": 300,
        "region": "us-east-1",
        "stat": "Average",
        "title": "OpenSearch Indexing Rate"
      }
    },
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
            "JVMMemoryPressure",
            "DomainName",
            "test-domain",
            "ClientId",
            "791437181286"
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
      "x": 0,
      "y": 0,
      "width": 6,
      "height": 6,
      "properties": {
        "metrics": [ 
          [
            "AWS/ES",
            "FreeStorageSpace",
            "DomainName",
            "test-domain",
            "ClientId",
            "791437181286"
          ]
        ],
        "period": 300,
        "region": "us-east-1",
        "stat": "Average",
        "title": "Free Storage Space"
      }
    }


  ]
}
EOF
}
