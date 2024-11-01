# Configure (specify the provider)

provider "aws" {
  region = "us-east-1"
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
  cidr_block        = "100.0.0.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "public_subnet-1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id     = aws_vpc.iac.id
  cidr_block = "100.0.1.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-2"
  }
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.iac.id
  cidr_block        = "100.0.2.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "private_subnet-1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id     = aws_vpc.iac.id
  cidr_block = "100.0.3.0/24"
  availability_zone = "us-east-1b"

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

# resource "aws_nat_gateway" "iac_nat" {
#   allocation_id = aws_eip.nat_eip.id  # Reference the Elastic IP for the NAT gateway
#   subnet_id     = aws_subnet.public_subnet.id
#   tags = {
#     Name = "nat_gateway"
#   }
# }

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

# resource "aws_route_table" "private_route_table" {
#   vpc_id = aws_vpc.iac.id

#   route {
#     cidr_block = "0.0.0.0/0"
#     nat_gateway_id = aws_nat_gateway.nat.id
#   }

#   tags = {
#     Name = "private_route_table"
#   }
# }

# resource "aws_route_table_association" "private_assoc_1" {
#   subnet_id      = aws_subnet.private_subnet_1.id
#   route_table_id = aws_route_table.private_route_table.id
# }

# resource "aws_route_table_association" "private_assoc_2" {
#   subnet_id      = aws_subnet.private_subnet_2.id
#   route_table_id = aws_route_table.private_route_table.id
# }

# Create Security Groups

#1. Web Security Group: Define the security group for the EC2 instance in the public subnet.

resource "aws_security_group" "web_sg" {
  vpc_id = aws_vpc.iac.id

  # Allow HTTP traffic on port 80.  #inbound traffic (ingress)

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    # Allow HTTPS traffic on port 443. Added an ingress rule for HTTPS (port 443) to allow secure HTTP traffic.

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow SSH traffic on port 22. Added an ingress rule for SSH (port 22) to allow secure remote access

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

 # Allow all outbound traffic (egress)

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

#2. Database Security Group: Define the security group for the RDS instance in the private subnet. 

# To create a Database Security Group for an RDS instance (or any database server) in a private subnet, 
# we will generally allow only necessary traffic, such as traffic from your application (e.g., EC2 instances) 
# to the database over specific ports (like 3306 for MySQL or 5432 for PostgreSQL). 
# We'll also typically restrict outbound traffic to allow database responses.

resource "aws_security_group" "db_sg" {
  vpc_id = aws_vpc.iac.id

# Allow inbound traffic from web instances on MySQL port (3306)
# Change port depending on the type of database (e.g., port 5432 for PostgreSQL, port 1433 for SQL Server).

# The security_groups attribute specifies that only traffic from your web/application instances (which belong to web_sg)
# can access the database. This is a common security practice to limit access to the database.

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.web_sg.id]     
  }

# Allow outbound traffic (egress)

# The egress rule allows all outbound traffic from the database security group.This is generally fine, 
# as databases often need to respond to queries or perform outbound operations.

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

# Create an EC2 Instance

resource "aws_instance" "web_server_2" {
  ami           = "ami-01e3c4a339a264cc9"  # AMI Amazon Linux 2 AMI in us-east-1 
  instance_type = "t2.micro"  # Instance type

  # Specify the key pair to use for SSH access
  
  # Associate the instance with the web security group and subnet
  subnet_id = aws_subnet.public_subnet_1.id  # Make sure this subnet is in a public VPC: Launch EC2 in public subnet
  security_groups = [aws_security_group.web_sg.id]  # Reference to the web security group: Associate the security group
 
# Optional if SSH is needed
#key_name = "shopsmartly-keypair"             

  # Root volume (EBS) configuration
  root_block_device {
    volume_type = "gp2"
    volume_size = 8  # Size in GB
    delete_on_termination = true
  }

  # Add tags for easier identification
  tags = {
    Name = "web_server_2"
  }

  # Optional: User data script to configure the instance at launch (e.g., install software) or
  #         : User data script to automatically install and run a web server

  # The user_data script installs and starts the Apache web server automatically when the EC2 instance is launched. 
  # It also creates a simple "Welcome" page.

  # user_data = <<-EOF
  #   #!/bin/bash
  #   yum update -y
  #   yum install -y nginx
  #   systemctl start nginx
  #   systemctl enable nginx
  # EOF
}  


# Terraform Commands:

# Once the code is complete, run the following commands in the terminal:

  # terraform init - Initialize Terraform to download necessary providers.
  # terraform plan - Preview the changes that Terraform will make.
  # terraform apply - Apply the configuration to create the resources.