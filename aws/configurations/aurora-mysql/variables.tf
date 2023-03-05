
variable "instance_class" {
    description = "Instance class of the nodes"
    type = string
    default = "db.t3.small"
}

variable "port" {
    description = "Port number"
    type = number
    default = 3306
}

