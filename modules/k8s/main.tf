resource "google_container_cluster" "gke-cluster" {
  name     = "my-gke-cluster"
  remove_default_node_pool = true
  initial_node_count       = 1  
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = "node1"
  cluster    = google_container_cluster.gke-cluster.id
  node_count = 1

  node_config {
    preemptible  = true
machine_type = "e2-micro"

  }
}

resource "kubernetes_namespace" "namespace" {

  metadata {
    name = "dev"
  }
}

resource "kubernetes_pod" "pod" {
  metadata {
    name = "ngnix-pod"
    labels = {
      app = "nginx"
    namespace = "dev"
    }
  }

  spec {
    container {
      image = "nginx"
      name  = "nginx"


    }
  }
}
resource "kubernetes_service" "service" {
  metadata {
    name = "project-demo-service"
    namespace = "dev"

  }
  spec {
    selector = {
      app = "${kubernetes_pod.pod.metadata.0.labels.app}"
    }
    port {
      port        = 80
      target_port = 80
    }

    type = "ClusterIP"
  }
}


# resource "kubernetes_ingress" "ingress" {
#   metadata {
#     name = "projet-demo-ingress"
#     namespace = "dev"
#   }

#   spec {
#     backend {
#       service_name = "project-demo-service"
#     }

#     rule {
#       http {
#         path {
#           backend {
#             service_name = "project-demo-service"
#           }

#           path = "/"
#         }   
#       }    
#     }

#   #   tls {
#   #     secret_name = "tls-secret"
#   #   }
#   }
# }
resource "google_compute_ssl_policy" "ssl-policy" {
  name            = "ssl-policy"
  min_tls_version = "TLS_1_2"
}

resource "kubernetes_ingress" "ingress2" {
  wait_for_load_balancer = true
  depends_on = [ kubernetes_manifest.frontendConfig ]
  metadata {
    name = "ingress2"
    namespace = "dev"
    annotations = {
      "kubernetes.io/ingress.class" = "nginx"
      "networking.gke.io/v1beta1.FrontendConfig" = kubernetes_manifest.frontendConfig.manifest.metadata.name
    }
  }
  spec {
    rule {
      host = "projeect.demo.numerixmd.com"
      http {
        path {
          # path = "/*"
          backend {
            service_name = "project-demo-service"
            service_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_manifest" "frontendConfig" {
  depends_on = [ google_compute_ssl_policy.ssl-policy ]
  manifest = {
    apiVersion = "networking.gke.io/v1beta1"
    kind       = "FrontendConfig"

    metadata = {
      name = "frontend-config"
      namespace = "dev"
    }

    spec = {
      sslPolicy = google_compute_ssl_policy.ssl-policy.name
    }
  }
}
