
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.51.0"
    }
    
  }
}

provider "google" {
  credentials = file("/home/aebouel/Terraform-GCP/project-demo-key.json")

  project = "project-demo-385203"
  region  = "us-central1"
  zone    = "us-central1-c"
}
data "google_client_config" "default" {}

provider "kubernetes" {
  
  host = "https://34.123.12.198"
  token                  = data.google_client_config.default.access_token
  client_certificate     = base64decode(module.k8s.gke-cluster.master_auth.0.client_certificate)
  client_key             = base64decode(module.k8s.gke-cluster.master_auth.0.client_key)
  cluster_ca_certificate = base64decode(module.k8s.gke-cluster.master_auth.0.cluster_ca_certificate)
}


resource "google_compute_network" "vpc_network" {
  name = "terraform-network"
}

