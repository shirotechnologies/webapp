
provider "aws" {
  region = "us-east-1"
}

data "aws_security_group" "allow_web" {
  filter {
    name   = "group-name"
    values = ["allow-web-to-aws-class"]
  }
}

resource "aws_instance" "ec2_with_terraform" {
  ami           = "ami-06c9bf7b301fc43f1"  # Existing AMI ID
  instance_type = "t2.micro"
  key_name      = "aws-class-web-server-key"

  # fetched Security Group ID
  vpc_security_group_ids = [data.aws_security_group.allow_web.id]
  
  # subnet ID for the VPC of the security group
  subnet_id = "subnet-03249c61ecf4a95ee" 

  tags = {
    Name = "ec2-with-terraform"
  }
}
