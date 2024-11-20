
resource "aws_iam_role" "irsa_role" {
  # for each role
  assume_role_policy = data.aws_iam_policy_document.trust_policy_for_iam_role.json
  name               = "${var.role_name}"
}



data "aws_iam_policy_document" "trust_policy_for_iam_role" {

  dynamic "statement" {
    for_each = toset(var.list_of_sa)

    content {
      actions = ["sts:AssumeRoleWithWebIdentity"]
      effect  = "Allow"

      condition {
        test     = "StringEquals"
        variable = "${replace(var.eks_url, "https://", "")}:sub"
        values   = ["system:serviceaccount:default:${statement.value}"]
      }

      principals {
        identifiers = [var.iam_openid_connect_provider_arn]
        type        = "Federated"
      }
    }

  }

}

resource "aws_iam_role_policy_attachment" "role_policy_attachment_irsa" {
#  for_each = toset(var.list_of_policy_arns)

    for_each = { for i,val in var.list_of_policy_arns : i => val }

  policy_arn = each.value
  role       = aws_iam_role.irsa_role.name
}


