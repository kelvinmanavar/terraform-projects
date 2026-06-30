resource "aws_vpc" "primary_vpc" {
  cidr_block       = var.primary_vpc_cidr
  provider        = aws.primary
  instance_tenancy = "default"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "primary-vpc-${var.primary}"
  }
}

resource "aws_vpc" "secondary_vpc" {
  cidr_block       = var.secondary_vpc_cidr
  provider        = aws.secondary 
  instance_tenancy = "default"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "secondary-vpc-${var.secondary}"
  }
}

resource "aws_subnet" "primary_subnet" {
  vpc_id            = aws_vpc.primary_vpc.id
  cidr_block        = var.primary_subnet_cidr
  availability_zone = data.aws_availability_zones.primary.names[0]
  provider          = aws.primary
  map_public_ip_on_launch = true

  tags = {
    Name = "primary-subnet-${var.primary}"
  }
}

resource "aws_subnet" "secondary_subnet" {
  vpc_id            = aws_vpc.secondary_vpc.id
  cidr_block        = var.secondary_subnet_cidr
  availability_zone = data.aws_availability_zones.secondary.names[0]
  provider          = aws.secondary
  map_public_ip_on_launch = true
  
  tags = {
    Name = "secondary-subnet-${var.secondary}"
  }
}

resource "aws_internet_gateway" "primary_igw" {
  vpc_id   = aws_vpc.primary_vpc.id
  provider = aws.primary

  tags = {
    Name = "primary-igw-${var.primary}"
  }
}

resource "aws_internet_gateway" "secondary_igw" {
  vpc_id   = aws_vpc.secondary_vpc.id
  provider = aws.secondary

  tags = {
    Name = "secondary-igw-${var.secondary}"
  }
}

resource "aws_route_table" "primary_route_table" {
  vpc_id   = aws_vpc.primary_vpc.id
  provider = aws.primary

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.primary_igw.id
  }

  tags = {
    Name = "primary-route-table-${var.primary}"
  }
}

resource "aws_route_table" "secondary_route_table" {
  vpc_id   = aws_vpc.secondary_vpc.id
  provider = aws.secondary

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.secondary_igw.id
  }

  tags = {
    Name = "secondary-route-table-${var.secondary}"
  }
}

resource "aws_route_table_association" "primary_route_table_association" {
  subnet_id      = aws_subnet.primary_subnet.id
  route_table_id = aws_route_table.primary_route_table.id
  provider       = aws.primary
}

resource "aws_route_table_association" "secondary_route_table_association" {
  subnet_id      = aws_subnet.secondary_subnet.id
  route_table_id = aws_route_table.secondary_route_table.id
  provider       = aws.secondary
}


resource "aws_vpc_peering_connection" "primary_to_secondary" {
  provider = aws.primary
  peer_vpc_id   = aws_vpc.secondary_vpc.id
  vpc_id        = aws_vpc.primary_vpc.id
  peer_region = var.secondary
  auto_accept = false

  tags = {
    Name = "primary-to-secondary-peering"
    Side        = "Requester"
  }

}

resource "aws_vpc_peering_connection_accepter" "secondary_to_primary" {
  provider = aws.secondary
  vpc_peering_connection_id = aws_vpc_peering_connection.primary_to_secondary.id
  auto_accept = true

  tags = {
    Name = "secondary-to-primary-peering"
    Side = "Accepter"
  }
}

resource "aws_route" "primary_to_secondary" {
  provider = aws.primary
  route_table_id = aws_route_table.primary_route_table.id
  destination_cidr_block = var.secondary_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.primary_to_secondary.id

  depends_on = [ aws_vpc_peering_connection.primary_to_secondary ]
}

resource "aws_route" "secondary_to_primary" {
  provider = aws.secondary
  route_table_id = aws_route_table.secondary_route_table.id
  destination_cidr_block = var.primary_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.primary_to_secondary.id

  depends_on = [ aws_vpc_peering_connection_accepter.secondary_to_primary ]
}

resource "aws_security_group" "primary_sg" {
  provider    = aws.primary
  name        = "primary-vpc-sg"
  description = "Security group for Primary VPC instance"
  vpc_id      = aws_vpc.primary_vpc.id

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ICMP from Secondary VPC"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.secondary_vpc_cidr]
  }

  ingress {
    description = "All traffic from Secondary VPC"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.secondary_vpc_cidr]
  }
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "Primary-VPC-SG"
  }
}

resource "aws_security_group" "secondary_sg" {
  provider    = aws.secondary
  name        = "secondary-vpc-sg"
  description = "Security group for Secondary VPC instance"
  vpc_id      = aws_vpc.secondary_vpc.id

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ICMP from Primary VPC"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.primary_vpc_cidr]
  }

  ingress {
    description = "All traffic from Primary VPC"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.primary_vpc_cidr]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "Secondary-VPC-SG"
  }
}

resource "aws_instance" "primary_instance" {
  provider               = aws.primary
  ami                    = data.aws_ami.primary_ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.primary_subnet.id
  vpc_security_group_ids = [aws_security_group.primary_sg.id]
  key_name               = var.primary_key_name

  user_data = local.primary_user_data

  tags = {
    Name        = "Primary-VPC-Instance"
    Region      = var.primary
  }

  depends_on = [aws_vpc_peering_connection_accepter.secondary_to_primary]
}

resource "aws_instance" "secondary_instance" {
  provider               = aws.secondary
  ami                    = data.aws_ami.secondary_ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.secondary_subnet.id
  vpc_security_group_ids = [aws_security_group.secondary_sg.id]
  key_name               = var.secondary_key_name

  user_data = local.secondary_user_data

  tags = {
    Name        = "Secondary-VPC-Instance"
    Region      = var.secondary
  }

  depends_on = [aws_vpc_peering_connection_accepter.secondary_to_primary]

}