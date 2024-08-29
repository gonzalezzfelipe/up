# TODO: this should be unified into a single module

locals {
  ext_workers_namespace = "ext-workers-v0"
}

resource "kubernetes_namespace_v1" "ext_workers" {
  metadata {
    name = local.ext_workers_namespace
  }
}

module "workers_crds" {
  source = "git::https://github.com/demeter-run/workloads.git//bootstrap/crds"
}

module "workers_configs" {
  source    = "git::https://github.com/demeter-run/workloads.git//bootstrap/configs"
  namespace = local.ext_workers_namespace
}

module "workers_operator" {
  depends_on    = [helm_release.kong]
  source        = "git::https://github.com/demeter-run/workloads.git//bootstrap/operator"
  namespace     = local.ext_workers_namespace
  cluster_name  = var.cluster_name
  cluster_alias = var.cluster_name # TODO: revisit this concept
  image_tag     = "3d94222b64ceb779dcb970d439d8b651621f2198"
}

