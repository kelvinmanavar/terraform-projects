terraform {
  backend "s3" {
    bucket = "terraform-state-bucket-22062026"
    key    = "infrastructure/staging/terraform.tfstate"
    region = "ap-south-1"
    encrypt      = true
    use_lockfile = true
  }
}