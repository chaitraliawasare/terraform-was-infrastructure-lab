terraform {
  backend "s3" {
    bucket       = "chaitrali-terraform-state"
    key          = "dec/terraform.tfstate"
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true
  }
}