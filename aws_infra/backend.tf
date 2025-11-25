terraform {
  backend "s3" {
    bucket         = "ashi0412-tfstate-bucket"          # create this first
    key            = "microservices/aws_infra/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock-table"             # create this too for locking
    encrypt        = true
  }
}
