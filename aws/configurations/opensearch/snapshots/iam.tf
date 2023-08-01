

resource "aws_iam_role" "snapshot_role" {
  name = "SnapshotRole"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Principal": {
        "Service": "es.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "snapshot_policy" {
  name        = "OS-SnapshotPolicy"
  description = "Policy to allow access to S3 bucket"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "s3:ListBucket"
        ],
        "Effect": "Allow",
        "Resource": [
          "arn:aws:s3:::${local.s3_bucket_name}"
        ]
      },
      {
        "Action": [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ],
        "Effect": "Allow",
        "Resource": [
          "arn:aws:s3:::${local.s3_bucket_name}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "s3_attachment" {
  policy_arn = aws_iam_policy.snapshot_policy.arn
  role       = aws_iam_role.snapshot_role.name
}

output "snapshot-role-arn" {
    value = aws_iam_role.snapshot_role.arn
}

