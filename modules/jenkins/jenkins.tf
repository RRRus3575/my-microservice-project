resource "kubernetes_namespace" "jenkins" {
  metadata { name = var.namespace }
}

resource "helm_release" "jenkins" {
  name             = var.release_name
  repository       = "https://charts.jenkins.io"
  chart            = "jenkins"
  namespace        = kubernetes_namespace.jenkins.metadata[0].name
  version          = var.chart_version
  create_namespace = false
  values           = [var.values_yaml]
}
