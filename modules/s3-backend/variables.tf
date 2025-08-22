variable "bucket_name" {
description = "Globally-unique S3 bucket name for Terraform state"
type = string
}


variable "table_name" {
description = "DynamoDB table name for Terraform state locks"
type = string
default = "terraform-locks"
}