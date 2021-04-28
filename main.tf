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

resource "aws_s3_bucket" "b" {
  bucket = "vishwakarma121235"
  acl    = "private"

  tags = {
    Name        = "Mybucket"
    Environment = "Dev"
   
  }
}