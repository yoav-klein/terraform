
variable "name" {
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

variable "public_subnet_tags" {
    default = {}
    description = "Tags for the public subnets"
    type = map(string)
}

variable "private_subnet_tags" {
    default = {}
    description = "Tags for the private subnets"
    type = map(string)
}

variable "auto_assign_public_ip" {
    description = "Whether or not to enable auto-assign public IP in the subnet"
    default = true
    type = bool
}
