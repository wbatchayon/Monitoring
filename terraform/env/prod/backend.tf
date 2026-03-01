# Terraform Backend Configuration for Production
# 
# ⚠️ WARNING: For production, use a remote backend!
# Options: S3, Azure, Consul, Terraform Cloud, etc.
#
# Current: Local backend (for initial setup, migrate to remote ASAP)
# 
# Production Backend Checklist:
# - [ ] Enable encryption at rest
# - [ ] Enable state locking (DynamoDB for S3)
# - [ ] Enable versioning
# - [ ] Restrict access via IAM
# - [ ] Monitor access logs

terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

# RECOMMENDED: S3 Backend for Production
# Uncomment and configure the following:
# terraform {
#   backend "s3" {
#     bucket         = "monitoring-terraform-state-prod"
#     key            = "prod/terraform.tfstate"
#     region         = "eu-west-1"
#     encrypt        = true
#     dynamodb_table = "terraform-locks"
#   }
# }

# RECOMMENDED: Terraform Cloud Backend
# Uncomment to use:
# terraform {
#   cloud {
#     organization = "your-org"
#     workspaces {
#       name = "monitoring-prod"
#     }
#   }
# }
