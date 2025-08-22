terraform {
backend "s3" {
bucket = "my-tfstate-3575857895123-lesson-5-west" 
key = "lesson-5/terraform.tfstate"
region = "us-west-2"
dynamodb_table = "terraform-locks-west" 
encrypt = true
}
}