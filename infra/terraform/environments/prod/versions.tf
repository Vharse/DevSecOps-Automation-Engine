terraform {
  required_version = ">= 1.6.0, < 2.0.0"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.32"
    }
  }

  # Configure a remote, locked backend before applying to production:
  # backend "s3" { ... } or backend "pg" { ... }
}
