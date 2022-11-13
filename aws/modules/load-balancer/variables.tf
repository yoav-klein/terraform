
variable "name" {
    type = string
    description = "Name for the Application Load Balancer"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID to place the load balancer in"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs to create load balancer nodes in"
}
