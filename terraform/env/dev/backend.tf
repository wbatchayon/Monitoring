# Terraform Backend Configuration
# This can be changed to use S3, Azure, GCS, etc. for production

terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}
