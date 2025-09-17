# Django App Deployment on AWS with Terraform, Jenkins, Argo CD, Prometheus & Grafana

## Description
This project provisions a complete AWS infrastructure with Terraform and deploys a Django application using Jenkins (CI), Argo CD (CD), and Helm.  
The stack includes VPC, EKS, RDS, ECR, Jenkins, Argo CD, Prometheus, and Grafana for monitoring.

---

## Infrastructure Components
- **S3 Backend + DynamoDB** – store and lock Terraform state  
- **VPC** – networking, subnets, routes, security groups  
- **ECR** – Docker image repository  
- **EKS** – Kubernetes cluster with AWS EBS CSI Driver  
- **RDS (Aurora optional)** – PostgreSQL database  
- **Jenkins** – CI pipeline with Kaniko executor  
- **Argo CD** – GitOps delivery (apps-of-apps pattern)  
- **Prometheus + Grafana** – monitoring stack via `kube-prometheus-stack`

---

## Files
```
Project/
├── main.tf
├── backend.tf
├── outputs.tf
├── rds_access.tf
├── terraform.tfvars
├── charts/
│   └── django-app/
│       ├── Chart.yaml
│       ├── values.yaml
│       └── templates/
│           ├── deployment.yaml
│           ├── service.yaml
│           ├── configmap.yaml
│           └── hpa.yaml
├── modules/
│   ├── s3-backend/
│   │   ├── s3.tf
│   │   ├── dynamodb.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── vpc/
│   │   ├── vpc.tf
│   │   ├── routes.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── ecr/
│   │   ├── ecr.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── eks/
│   │   ├── eks.tf
│   │   ├── aws_ebs_csi_driver.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── rds/
│   │   ├── rds.tf
│   │   ├── aurora.tf
│   │   ├── shared.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── jenkins/
│   │   ├── jenkins.tf
│   │   ├── providers.tf
│   │   ├── variables.tf
│   │   ├── values.yaml
│   │   └── outputs.tf
│   ├── argo_cd/
│   │   ├── argo.tf
│   │   ├── providers.tf
│   │   ├── variables.tf
│   │   ├── values.yaml
│   │   ├── outputs.tf
│   │   └── charts/
│   │       └── argocd-apps/
│   │           ├── Chart.yaml
│   │           ├── values.yaml   # repoURL=https://github.com/RRRus3575/my-microservice-project.git, targetRevision=final_project, path=charts/django-app
│   │           └── templates/
│   │               └── application.yaml
│   └── monitoring/
│       ├── providers.tf
│       ├── variables.tf
│       ├── monitoring.tf
│       ├── values.yaml
│       └── outputs.tf
└── Django/
    ├── app/
    ├── Dockerfile
    ├── Jenkinsfile
    └── docker-compose.yaml
```

---

## Bootstrap Backend
1. Initialize Terraform and create S3 bucket + DynamoDB table:  
   ```bash
   terraform init
   terraform apply -target=module.s3_backend
   ```
2. Re-initialize backend:  
   ```bash
   terraform init
   ```

---

## Deploy Infrastructure
```bash
terraform apply
```

---

## Verify Resources
```bash
kubectl get all -n jenkins
kubectl get all -n argocd
kubectl get all -n monitoring
```

---

## Jenkins & Argo CD Access
```bash
kubectl port-forward svc/jenkins 8080:8080 -n jenkins
kubectl port-forward svc/argocd-server 8081:443 -n argocd
```
- Retrieve admin passwords from Terraform outputs or Kubernetes secrets.

---

## Monitoring (Prometheus + Grafana)
1. **Create Grafana secret** (required because `values.yaml` uses `existingSecret`):  
   ```bash
   kubectl create secret generic grafana-admin      --from-literal=admin-user=admin      --from-literal=admin-password='S0m3$Str0ng_Passw0rd!'      -n monitoring
   ```
2. Check resources:  
   ```bash
   kubectl get all -n monitoring
   ```
3. Port-forward Grafana:  
   ```bash
   kubectl port-forward svc/grafana 3000:80 -n monitoring
   ```

---

## Application Deployment (via Argo CD)
Argo CD apps-of-apps is configured to track:
- **repoURL:** `https://github.com/RRRus3575/my-microservice-project.git`
- **targetRevision:** `final_project`
- **path:** `charts/django-app`
- **namespace:** `apps`

Argo CD automatically syncs when a new image tag is pushed by Jenkins.

---

## Clean-Up
> ⚠️ To avoid unexpected charges, always destroy unused resources:  
```bash
terraform destroy
```
> `terraform destroy` also deletes the S3 bucket and DynamoDB table for your backend state. To redeploy, recreate them first.
