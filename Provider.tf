provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      project = "LABS_Modules"
      CostCenter = "10.20.30"
      Environment = "DEV"

    }
  }
}