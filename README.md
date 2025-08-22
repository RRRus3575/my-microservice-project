# lesson-5 — Terraform on AWS (S3 backend, DynamoDB locks, VPC, ECR)


## Prerequisites
- Terraform >= 1.6
- AWS credentials available in your shell (e.g. via `aws configure` or environment variables)
- Choose a **globally-unique** S3 bucket name for state, e.g. `my-tfstate-<account-id>-lesson-5`


## Files
- `backend.tf` — S3 backend configuration (enable AFTER bootstrapping)
- `main.tf` — providers + module wiring
- `outputs.tf` — consolidated outputs
- `modules/s3-backend` — S3 bucket (versioned) + DynamoDB table for state locks
- `modules/vpc` — VPC with 3 public + 3 private subnets, IGW, single NAT GW, shared RTs
- `modules/ecr` — ECR repository with scan-on-push and a minimal policy


## ⚠️ Backend bootstrapping (first run)
1. Edit `main.tf` variables (or create `terraform.tfvars`) and set:
- `backend_bucket_name` = your unique bucket
- `backend_table_name` = `terraform-locks` (or your preferred name)
2. **Temporarily disable** the remote backend by renaming `backend.tf` to `backend.tf.disabled` (or comment its contents).
3. Init and create only the backend resources locally:
```bash
terraform init
terraform apply -target=module.s3_backend
```
4. Restore `backend.tf` and initialize remote state, migrating automatically:
```bash
mv backend.tf.disabled backend.tf # if you renamed it
terraform init -migrate-state
```


## Create all infrastructure
```bash
terraform plan
terraform apply
```


## Destroy
```bash
terraform destroy
```


> Note: NAT Gateway incurs hourly + data processing charges. This example uses **one** NAT to save costs. For HA, create one per AZ.


## ECR usage tips
- Authenticate Docker to ECR (example for current region):
```bash
aws ecr get-login-password --region $(terraform output -raw aws_region 2>/dev/null || echo us-west-2) \
| docker login --username AWS --password-stdin $(terraform output -raw ecr_repository_url | cut -d'/' -f1)
```
- Build & push an image:
```bash
export REPO=$(terraform output -raw ecr_repository_url)
docker build -t $REPO:latest .
docker push $REPO:latest
```