locals {}

module "k8s" {
  source = "../modules/k8s"
  
  #provider "kubernetes" {
   # host = "https://34.123.12.198"

    #client_certificate     = module.google_container_cluster.gke-cluster.master_auth.0.client_certificate
   # client_key             = module.google_container_cluster.gke-cluster.master_auth.0.client_key
 #   cluster_ca_certificate = module.google_container_cluster.gke-cluster.master_auth.0.cluster_ca_certificate
#  }
  	
}
