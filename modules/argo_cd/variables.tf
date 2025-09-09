variable "namespace"       { type = string  default = "argocd" }
variable "release_name"    { type = string  default = "argo-cd" }
variable "chart_version"   { type = string  default = "7.6.12" } # argo/argo-cd
variable "cluster_endpoint"{ type = string }
variable "cluster_ca"      { type = string }
variable "cluster_token"   { type = string }
variable "values_yaml"     { type = string  description = "Inline Helm values.yaml for Argo CD" }
variable "apps_namespace"  { type = string  default = "apps" }
variable "apps_repo_url"   { type = string  description = "Git repo with Helm chart(s) (https url)" }
variable "apps_repo_rev"   { type = string  default = "main" }
variable "helm_chart_path" { type = string  default = "charts/django-app" }
variable "app_name"        { type = string  default = "django-app" }
