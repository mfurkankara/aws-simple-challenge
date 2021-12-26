resource "aws_vpc" "ec2-vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  enable_classiclink   = "false"
  instance_tenancy     = "default"
  tags = {
    Name = "ec2-vpc"
  }
}

resource "aws_subnet" "ec2-subnet-public-1" {
  vpc_id                  = aws_vpc.ec2-vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "eu-central-1a"
  tags = {
    Name = "ec2-subnet-public-1"
  }
}

resource "aws_subnet" "ec2-subnet-public-2" {
  vpc_id                  = aws_vpc.ec2-vpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "eu-central-1b"
  tags = {
    Name = "ec2-subnet-public-2"
  }
}

resource "aws_subnet" "ec2-subnet-private-1" {
  vpc_id                  = aws_vpc.ec2-vpc.id
  cidr_block              = "10.0.3.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "eu-central-1a"
  tags = {
    Name = "ec2-subnet-private-1"
  }
}

resource "aws_subnet" "ec2-subnet-private-2" {
  vpc_id                  = aws_vpc.ec2-vpc.id
  cidr_block              = "10.0.4.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "eu-central-1b"
  tags = {
    Name = "ec2-subnet-private-2"
  }
}

resource "aws_internet_gateway" "ec2-igw" {
  vpc_id = aws_vpc.ec2-vpc.id
  tags = {
    Name = "ec2-igw"
  }
}
