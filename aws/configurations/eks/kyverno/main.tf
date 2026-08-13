

module "eks_cluster" {
    source = "../../../modules/eks"
    cluster_name = "yoav"
    node_count = 2    
}
