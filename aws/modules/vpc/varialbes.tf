
variable "vpc_name" {
  type    = string
  default = "my-vpc"
}

variable "cidr" {
    description = "The CIDR range for the VPC"
    type = string
}

variable "public_subnets" {
    description = "A list of public subnets to create in the VPC"
    default = []
    type = list(object({
        cidr = string
        az = string
    }))
}

variable "private_subnets" {
    description = "A list of privaate subnets to create in the VPC"
    default = []
    type = list(object({
        cidr = string
        az = string
    }))
}
