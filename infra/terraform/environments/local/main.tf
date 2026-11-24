provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "kind-devsecops-lab"
}

module "app_namespace" {
  source      = "../../modules/k8s-namespace"
  name        = "devsecops-lab"
  environment = "local"
}
