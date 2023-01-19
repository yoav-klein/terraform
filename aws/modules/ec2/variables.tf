
variable "instance_type" {
    type = string
    description = "Instance type"
    default = "t2.small"
}

variable "default_vpc" {
    type = bool
    description = "Should deploy the EC2 instances in the default VPC"
    default = true
}

variable "vpc_id" {
    type = string
    description = "VPC ID - irrelevant if default_vpc is set to true"
    default = ""
}

variable "instance_count" {
    type = number
    description = "Number of instances"
}

variable "subnet_ids" {
    type = list(string)
    description = "Subnets to run the instances in. irrelevant If default_vpc is true"
    default = [""]
}

variable "pub_key_path" {
    type = string
    description = "Path to a public key"
}

variable "use_default_sg" {
    type = bool
    description = "Should use deafult Security group (SSH, HTTP and HTTPS)"
    default = true
}

variable "security_group_ids" {
    default = []
    description = "List of security groups to associate with the insatces"
    type = list(string)
}
