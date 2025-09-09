resource "kubernetes_namespace" "argocd" {
  metadata { name = var.namespace }
}

resource "helm_release" "argocd" {
  name             = var.release_name
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = kubernetes_namespace.argocd.metadata[0].name
  version          = var.chart_version
  create_namespace = false
  values           = [var.values_yaml]
}

resource "kubernetes_namespace" "apps" {
  metadata { name = var.apps_namespace }
}

resource "helm_release" "apps_of_apps" {
  name       = "apps"
  chart      = "${path.module}/charts/argocd-apps"
  namespace  = kubernetes_namespace.argocd.metadata[0].name
  depends_on = [helm_release.argocd]

  set { name = "applications[0].name"                     value = var.app_name }
  set { name = "applications[0].project"                  value = "default" }
  set { name = "applications[0].source.repoURL"           value = var.apps_repo_url }
  set { name = "applications[0].source.targetRevision"    value = var.apps_repo_rev }
  set { name = "applications[0].source.path"              value = var.helm_chart_path }
  set { name = "applications[0].destination.namespace"    value = var.apps_namespace }
  set { name = "applications[0].destination.server"       value = "https://kubernetes.default.svc" }
}
