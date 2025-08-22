output "bucket_name" {
value = aws_s3_bucket.tf_state.bucket
description = "Name of the S3 bucket for tfstate"
}


output "bucket_arn" {
value = aws_s3_bucket.tf_state.arn
description = "ARN of the S3 bucket"
}


output "table_name" {
value = aws_dynamodb_table.tf_locks.name
description = "DynamoDB table name for locks"
}


output "table_arn" {
value = aws_dynamodb_table.tf_locks.arn
description = "DynamoDB table ARN"
}