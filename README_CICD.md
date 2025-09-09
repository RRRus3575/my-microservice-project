# CI/CD: Jenkins + Helm + Terraform + Argo CD

## Що додано
- Модулі Terraform: `modules/jenkins`, `modules/argo_cd`.
- Jenkinsfile з Kubernetes agent (Kaniko) для ECR + оновлення тегу у Helm.
- Helm chart `modules/argo_cd/charts/argocd-apps` для створення Argo CD Application.

## Як підключити модулі в main.tf
```hcl
data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name
}

module "jenkins" {
  source           = "./modules/jenkins"
  cluster_endpoint = module.eks.cluster_endpoint
  cluster_ca       = module.eks.cluster_certificate_authority_data
  cluster_token    = data.aws_eks_cluster_auth.this.token
  values_yaml      = file("./modules/jenkins/values.yaml")
}

module "argo_cd" {
  source            = "./modules/argo_cd"
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_ca        = module.eks.cluster_certificate_authority_data
  cluster_token     = data.aws_eks_cluster_auth.this.token
  values_yaml       = file("./modules/argo_cd/values.yaml")
  apps_repo_url     = "https://github.com/<you>/<helm-repo>.git"
  apps_repo_rev     = "main"
  helm_chart_path   = "charts/django-app"
  app_name          = "django-app"
}
```

## Jenkins креденшели
- `aws-creds` як Kubernetes Secret (region, access_key_id, secret_access_key) для агента.
- Jenkins ID `helm-git-cred` для пушу у Helm-репозиторій.
- Параметри збірки: `ECR_URL`, `HELM_REPO_URL`.

## Потік
1. Jenkins збирає образ Kaniko → пушить в ECR (теги: `SHA`, `build-N`).
2. Jenkins оновлює `charts/django-app/values.yaml:image.tag` у Helm-репозиторії.
3. Argo CD відслідковує репозиторій → автосинхронізує у кластері.
