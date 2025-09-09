variable "namespace"       { type = string  default = "jenkins" }
variable "release_name"    { type = string  default = "cd-jenkins" }
variable "chart_version"   { type = string  default = "5.3.6" } # jenkinsci/jenkins
variable "cluster_endpoint"{ type = string }
variable "cluster_ca"      { type = string }
variable "cluster_token"   { type = string }
variable "values_yaml"     { type = string  description = "Inline Helm values.yaml for Jenkins" }
