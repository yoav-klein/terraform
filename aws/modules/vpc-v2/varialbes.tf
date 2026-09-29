
variable "name" {
  type    = string
  default = "my-vpc"
}

variable "cidr" {
    description = "The CIDR range for the VPC"
    type = string
}

variable "public_subnets" {
    description = "A list of CIRDs for public subnets"
    default = []
    type = list(string)
}

variable "private_subnets" {
    description = "A list of CIRDs for private subnets"
    default = []
    type = list(string)
}

variable "create_nat_gateway" {
    description = "Whether or not to creaete a NAT gateway"
    default = false
    type = bool
}

variable "auto_assign_public_ip" {
    description = "Whether or not to enable auto-assign public IP in the subnet"
    default = true
    type = bool
}
