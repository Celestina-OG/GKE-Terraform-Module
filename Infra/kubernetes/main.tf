provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "kubernetes_namespace" "default" {
  metadata {
    name = "time-api"
  }
}

resource "kubernetes_deployment" "api_deployment" {
  metadata {
    name      = "api-deployment"
    namespace = kubernetes_namespace.default.metadata[0].name
    labels = {
      app = "time-api"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "time-api"
      }
    }

    template {
      metadata {
        labels = {
          app = "time-api"
        }
      }

      spec {
        container {
          name  = "time-api"
          image = "gcr.io/${var.project_id}/time-api:latest"

          port {
            container_port = 8080
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "api_service" {
  metadata {
    name      = "api-service"
    namespace = kubernetes_namespace.default.metadata[0].name
  }

  spec {
    selector = {
      app = "time-api"
    }

    port {
      protocol = "TCP"
      port     = 80
      target_port = 8080
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_ingress_v1" "api_ingress" {
  metadata {
    name      = "api-ingress"
    namespace = kubernetes_namespace.default.metadata[0].name
    annotations = {
      "nginx.ingress.kubernetes.io/whitelist-source-range" = "0.0.0.0/0"
    }
  }

  spec {
    ingress_class_name = "nginx"
    rule {
      http {
        path {
          path     = "/time"
          path_type = "ImplementationSpecific"
          backend {
            service {
              name = kubernetes_service.api_service.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}
