
provider "aws" {
  profile = "default"
  region  = "us-east-2"
}

resource "aws_instance" "example" {
  ami           = "ami-0b0f4c27376f8aa79"
  instance_type = "t2.micro"
}

