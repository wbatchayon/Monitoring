# Terraform Backend Configuration for Staging
# 
# ⚠️ WARNING: Use remote backend for production-like environments
#
# Current: Local backend (for initial setup)

terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

# RECOMMENDED: S3 Backend for Staging
# Uncomment and configure:
# terraform {
#   backend "s3" {
#     bucket         = "monitoring-terraform-state-stag"
#     key            = "stag/terraform.tfstate"
#     region         = "eu-west-1"
#     encrypt        = true
#     dynamodb_table = "terraform-locks"
#   }
# }
