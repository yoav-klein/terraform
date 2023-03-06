
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

variable "security_group_ids" {
    description = "List of security groups to attach to cluster"
    type = list(string)
    default = []
}

variable "port" {
    description = "Port number"
    type = number
    default = 3306
}

variable "publicly_accessible" {
    description = "Should the cluster be publicly accessible"
    type = bool
    default = false
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
