variable "namespace" {
  description = "Namespace for monitoring stack"
  type        = string
  default     = "monitoring"
}

variable "release_name" {
  description = "Helm release name for kube-prometheus-stack"
  type        = string
  default     = "kube-prom-stack"
}

variable "chart_version" {
  description = "kube-prometheus-stack chart version"
  type        = string
  # зафіксуй стабільну версію, за потреби онови
  default     = "65.5.0"
}

variable "values_yaml" {
  description = "Optional Helm values (YAML) as string"
  type        = string
  default     = ""
}
