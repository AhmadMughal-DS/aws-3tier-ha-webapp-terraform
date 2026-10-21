# Remote state backend (production).
#
# Bootstrap once (an S3 bucket with versioning + encryption and a DynamoDB lock
# table), then uncomment this block and run `terraform init -migrate-state`.
#
# terraform {
#   backend "s3" {
#     bucket         = "ahmad-tfstate-<account-id>"
#     key            = "aws-3tier-ha-webapp/terraform.tfstate"
#     region         = "us-east-1"
#     dynamodb_table = "ahmad-tf-locks"
#     encrypt        = true
#   }
# }
