
# creating a user named "john"

resource "aws_iam_user" "john" {
  name = "john"
}

resource "aws_iam_access_key" "john" {
  user = aws_iam_user.john.name
}


output "access_key_id" {
    value = aws_iam_access_key.john.id
}

resource "local_sensitive_file" "foo" {
  content  = aws_iam_access_key.john.secret
  filename = "${path.module}/secret_access_key"
}

# creating an acces entry for john, and associating an access policy with it
resource "aws_eks_access_entry" "john" {
  cluster_name      = aws_eks_cluster.this.name
  principal_arn     = aws_iam_user.john.arn
  type              = "STANDARD"
}

resource "aws_eks_access_policy_association" "john" {
  cluster_name      = aws_eks_cluster.this.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
  principal_arn     = aws_iam_user.john.arn

  access_scope {
    type       = "namespace"
    namespaces = ["default"]
  }
}
