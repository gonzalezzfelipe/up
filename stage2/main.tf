terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.22.0"
    }
  }
}

provider "kubernetes" {
  config_path    = var.k8s_config
  config_context = var.k8s_context
}

provider "helm" {
  kubernetes {
    config_path    = var.k8s_config
    config_context = var.k8s_context
  }
}

locals {
  acme_account_email = try(var.acme_account_email, null)
  ingress_classes = {
    "aws" = "alb"
    "gcp" = "gce"
  }
}

module "cert_manager" {
  source             = "../modules/common/cert-manager/stage2"
  acme_account_email = local.acme_account_email
}

resource "kubernetes_ingress_v1" "cert_manager_webhook" {
  metadata {
    name      = "cert-manager-webhook"
    namespace = "cert-manager"
    annotations = {
      "kubernetes.io/ingress.class" = "gce"
    }
  }

  spec {
    rule {
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "cert-manager-webhook"
              port {
                number = 443
              }
            }
          }
        }
      }
    }
  }
}


# module "grafana_tempo" {
#   source    = "../modules/grafana-tempo/stage2"
#   namespace = var.dmtr_namespace
# }

# module "postgresql" {
#   source = "../modules/postgresql/stage2"
# }

module "o11y" {
  source    = "../modules/common/o11y/stage2"
  namespace = var.dmtr_namespace
}

module "dmtrd" {
  source        = "../modules/common/dmtrd/stage2"
  namespace     = var.dmtr_namespace
  dmtrd_version = var.dmtrd_version
}
