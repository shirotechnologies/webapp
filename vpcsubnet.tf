provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "iac" {
  cidr_block = "100.0.0.0/22"

  tags = {
    Name = "iac-vpc"
  }
}

resource "aws_internet_gateway" "iacgw" {
  vpc_id = aws_vpc.iac.id

  tags = {
    Name = "iac"
  }
}

# resource "aws_internet_gateway_attachment" "iac" {
#   internet_gateway_id = aws_internet_gateway.iacgw.id
#   vpc_id              = aws_vpc.iac.id
# }



resource "aws_subnet" "public_subnet_1" {
  vpc_id     = aws_vpc.iac.id
  cidr_block = "100.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-1"
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

resource "aws_subnet" "private_subnet_1" {
  vpc_id     = aws_vpc.iac.id
  cidr_block = "100.0.3.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "private-subnet-1"
  }
}

# resource "aws_subnet" "private_subnet_2" {
#   vpc_id     = aws_vpc.iac.id
#   cidr_block = "175.0.175.0/28"
#   availability_zone = "us-east-1b"

#   tags = {
#     Name = "private-subnet-2"
#   }
# }

# resource "aws_route" "route1" {
#   route_table_id            = aws_route_table.testing.id
#   destination_cidr_block    = "100.0.4.0/24"
# }

# # Create the route tables
# resource "aws_route_table" "public_route" {
#   vpc_id = aws_vpc.iac.id

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.route1.id
#   }

#   tags = {
#     Name = "public-route-table"
#   }
# }

# resource "aws_route_table" "private_route" {
#   vpc_id = aws_vpc.iac.id

#   tags = {
#     Name = "private-route-table"
#   }
# }

# # Assign route tables to subnets
# resource "aws_route_table_association" "public_route_assoc_1" {
#   subnet_id      = aws_subnet.public_subnet_1.id
#   route_table_id = aws_route_table.public_route.id
# }

# resource "aws_route_table_association" "public_route_assoc_2" {
#   subnet_id      = aws_subnet.public_subnet_2.id
#   route_table_id = aws_route_table.public_route.id
# }

# resource "aws_route_table_association" "private_route_assoc_1" {
#   subnet_id      = aws_subnet.private_subnet_1.id
#   route_table_id = aws_route_table.private_route.id
# }

# resource "aws_route_table_association" "private_route_assoc_2" {
#   subnet_id      = aws_subnet.private_subnet_2.id
#   route_table_id = aws_route_table.private_route.id
# }
