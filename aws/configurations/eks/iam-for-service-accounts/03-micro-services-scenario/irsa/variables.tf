
variable "eks_url" {
    type = string
}

variable "iam_openid_connect_provider_arn" {
    type = string
}

variable "role_name" {
    type = string
}

variable "list_of_sa" {
  type = list(string)
}

variable "list_of_policy_arns" {
  type = list(string)
}
