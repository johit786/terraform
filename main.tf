provider "aws" {
  region                  = "us-east-1"
    
}

resource "aws_instance" "Aakash"{
   ami           = "ami-0742b4e673072066f"
   instance_type = "t2.micro"
   tags = {
    "Name" = "My-server-with-terraform"
  }
}

# resource "aws_s3_bucket" "b" {
#   bucket = "vishwakarma121235"
#   acl    = "private"

#   tags = {
#     Name        = "Mybucket"
#     Environment = "Dev"
   
#   }
#}
resource "aws_s3_bucket" "this" {
  count = var.create_bucket ? 1 : 0

  bucket        = var.bucket
  bucket_prefix = var.bucket_prefix
}