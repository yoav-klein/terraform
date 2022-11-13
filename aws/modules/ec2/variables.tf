
variable "default_vpc" {
    type = bool
    description = "Should deploy the EC2 instances in the default VPC"
    default = true
}

variable "instance_count" {
    type = number
    description = "Number of instances"
}

variable "subnet_ids" {
    type = list(string)
    description = "Subnets to run the instances in. If default_vpc is true, this is useless"
    default = ""
}

variable "pub_key_path" {
    type = string
    description = "Path to a public key"
}

