output "namespace_name" {
  description = "Created Kubernetes namespace name"
  value       = kubernetes_namespace.this.metadata[0].name
}
