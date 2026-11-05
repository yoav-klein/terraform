
variable "cluster_name" {
    type = string
    description = "Cluster name"    
}

variable "node_count" {
    type = number
    description = "Number of nodes"
}

variable "cluster_subnet_ids" {
    type = list(string)
    description = "Subnet IDs for cluster"
}

variable "node_subnet_ids" {
    type = list(string)
    description = "Subnet IDs for nodes"
}
