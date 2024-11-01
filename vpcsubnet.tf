provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "berni" {
  cidr_block = "100.0.0.0/16"

  tags = {
    Name = "berni-vpc"
  }
}

resource "aws_internet_gateway" "bernigw" {
  vpc_id = aws_vpc.berni.id

  tags = {
    Name = "berni-igw"
  }
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id     = aws_vpc.berni.id
  cidr_block = "100.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-1"
  }
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id     = aws_vpc.berni.id
  cidr_block = "100.0.3.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "private-subnet-1"
  }
}
