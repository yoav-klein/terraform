###################################################
#
# Create an OIDC provider configuration for the cluster
#
###################################################



# get the certificates for the provider in order to get the fingerprint
data "tls_certificate" "this" {
  url = aws_eks_cluster.this.identity[0].oidc[0].issuer
}


resource "aws_iam_openid_connect_provider" "this" {
  url = data.tls_certificate.this.url
  thumbprint_list = data.tls_certificate.this.certificates[*].sha1_fingerprint
  client_id_list = ["sts.amazonaws.com"]
}


locals {
    role_policies_sas = {
        developer = [ [aws_iam_policy.read_s3.arn], ["developer"] ]
        grocery-service = [ [aws_iam_policy.read_s3.arn, "arn:aws:iam::aws:policy/AlexaForBusinessFullAccess"], ["grocery-sa", "shopping-sa"] ]
    }

}


module "irsa" {
    for_each = local.role_policies_sas
    source = "./irsa"
    
    eks_url = aws_iam_openid_connect_provider.this.url
    iam_openid_connect_provider_arn = aws_iam_openid_connect_provider.this.arn
    role_name = each.key
    list_of_sa = each.value[1]
    list_of_policy_arns = each.value[0]
}


