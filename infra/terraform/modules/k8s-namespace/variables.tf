variable "name" {
  description = "Name of the Kubernetes namespace"
  type        = string
}

variable "environment" {
  description = "Environment label (e.g., local, prod)"
  type        = string
}

variable "labels" {
  description = "Additional labels to apply to the namespace"
  type        = map(string)
  default     = {}
}
