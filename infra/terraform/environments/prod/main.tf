provider "kubernetes" {
  # Provide production cluster auth via environment/kubeconfig/OIDC in CI or isolated runner
}

module "app_namespace" {
  source      = "../../modules/k8s-namespace"
  name        = "devsecops-prod"
  environment = "prod"
}
