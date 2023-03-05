
variable "name" {
    description = "Cluster name"
    type = string
}

variable "instance_class" {
    description = "Instance class of the nodes"
    type = string
    default = "db.t3.small"
}

variable "num_instances" {
    description = "Number of instances - primary and replicas"
    type = number
    default = 3
}   

variable "port" {
    description = "Port number"
    type = number
    default = 3306
}

variable "username" {
    description = "Master username for database"
    type = string
    default = "admin"
}

variable "password" {
    description = "Master password"
    type = string
    sensitive = true
}

variable "vpc_id" {
    description = "VPC ID"
    type = string
}

variable "subnet_ids" {
    description = "List of subnet IDs"
    type = list(string)
}
