# lesson-7 — Terraform on AWS (S3 backend, DynamoDB locks, VPC, ECR, EKS, Helm)

## Prerequisites
- Terraform >= 1.6
- AWS credentials available in your shell (e.g. via `aws configure` or environment variables)
- kubectl and helm installed locally
- Docker installed (for building and pushing images)
- Choose a **globally-unique** S3 bucket name for state, e.g. `my-tfstate-<account-id>-lesson-7`

---

## Files
- `backend.tf` — S3 backend configuration (enable AFTER bootstrapping)
- `main.tf` — providers + module wiring
- `outputs.tf` — consolidated outputs
- `terraform.tfvars` — variable values (bucket, vpc, ecr_name, etc.)
- `modules/s3-backend` — S3 bucket (versioned) + DynamoDB table for state locks
- `modules/vpc` — VPC with 3 public + 3 private subnets, IGW, single NAT GW, shared RTs
- `modules/ecr` — ECR repository with scan-on-push and a minimal policy
- `modules/eks` — EKS cluster with worker nodes
- `charts/django-app` — Helm chart for the Django app (Deployment, Service, ConfigMap, HPA)

---

## ⚠️ Backend bootstrapping (first run)
1. Edit `terraform.tfvars` and set:
   - `backend_bucket_name` = your unique bucket  
   - `backend_table_name` = `terraform-locks` (or your preferred name)

2. **Temporarily disable** the remote backend by renaming `backend.tf` to `backend.tf.disabled` (or comment its contents).

3. Init and create only the backend resources locally:
```bash
terraform init -backend=false
terraform apply -target=module.s3_backend
```

4. Restore `backend.tf` and initialize remote state, migrating automatically:
```bash
mv backend.tf.disabled backend.tf
terraform init -migrate-state
```

---

## Create all infrastructure
```bash
terraform plan -var-file="terraform.tfvars"
terraform apply -auto-approve -var-file="terraform.tfvars"
```

---

## Connect to EKS cluster
```bash
aws eks update-kubeconfig --name $(terraform output -raw eks_cluster_name) --region us-west-2
kubectl get nodes
```

---

## ECR usage

- Authenticate Docker to ECR
```bash
aws ecr get-login-password --region us-west-2 \
| docker login --username AWS --password-stdin $(terraform output -raw ecr_repository_url | cut -d'/' -f1)
```

- Build & push an image
```bash
export REPO=$(terraform output -raw ecr_repository_url)
docker build -t $REPO:v1 .
docker push $REPO:v1
```

---

## Deploy Django app with Helm

- Install metrics-server (required for HPA)
```bash
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm repo update
helm install metrics-server metrics-server/metrics-server \
  --namespace kube-system \
  --set args={"--kubelet-insecure-tls","--kubelet-preferred-address-types=InternalIP,Hostname,ExternalIP"}
```
- Deploy the application
```bash
helm upgrade --install django-app ./charts/django-app -n default
```

- Verify resources
```bash
kubectl get pods,svc,hpa -n default
```

## Destroy
```bash
terraform destroy -var-file="terraform.tfvars"
```
