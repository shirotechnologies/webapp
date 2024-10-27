provider "aws" {
  region     = "us-east-1"  # Specify the AWS region
}

# Initialize Terraform: This will download the necessary providers and set up your working environment.
# Run "terraform init" in the Terminal.

# Create a VPC in the main.tf:

resource "aws_vpc" "iac" {
  cidr_block = "100.0.0.0/22"   ## Specify the CIDR block for the VPC
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "iac_vpc"
  }
}

#Define the Public and Private Subnets. Add this to your main.tf file to create public and private subnets within the VPC:

resource "aws_subnet" "public_subnet_1" {
  vpc_id            = aws_vpc.iac.id
  cidr_block        = "100.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "public_subnet-1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id     = aws_vpc.iac.id
  cidr_block = "100.0.2.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-2"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "private_subnet"
  }
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id     = aws_vpc.iac.id
  cidr_block = "100.0.3.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "private-subnet-1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id     = aws_vpc.iac.id
  cidr_block = "100.0.1.4/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "private-subnet-2"
  }
}

# Create Internet and NAT Gateways:
# Internet Gateway for Public Access:Add an Internet Gateway so your public subnet resources can access the internet:

resource "aws_internet_gateway" "iac_igw" {
  vpc_id = aws_vpc.iac.id
  tags = {
    Name = "iac-igw"
  }
}

# NAT Gateway for Private Subnet:
# For the private subnet resources to access the internet (e.g., for updates), create a NAT Gateway:
# The allocation_id should refer to the Elastic IP associated with the NAT Gateway, not the VPC ID.

resource "aws_nat_gateway" "iac_nat" {
  allocation_id = aws_eip.nat_eip.id  # Reference the Elastic IP for the NAT gateway
  subnet_id     = aws_subnet.public_subnet.id
  tags = {
    Name = "nat_gateway"
  }
}

# Create Route Tables:
# Public Route Table: Associate the Internet Gateway with the public route table:

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.iac.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.iac_igw.id
  }

  tags = {
    Name = "public_route_table"
  }
}

resource "aws_route_table_association" "public_route_assoc_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_assoc_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_route_table.id
}

# Private Route Table with NAT Gateway: This route table allows private subnet resources to communicate with the internet via the NAT Gateway.

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.iac.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "private_route_table"
  }
}

resource "aws_route_table_association" "private_assoc_1" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_assoc_2" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_route_table.id
}

# Create Security Groups
# Web Security Group: Define the security group for the EC2 instance in the public subnet.

resource "aws_security_group" "web_sg" {
  vpc_id = aws_vpc.iac.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "web_sg"
  }
}

# Database Security Group: Define the security group for the RDS instance in the private subnet. 

resource "aws_security_group" "db_sg" {
  vpc_id = aws_vpc.iac.id
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "db_sg"
  }
}
