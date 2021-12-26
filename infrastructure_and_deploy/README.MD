
## Login To AWS

```bash
$ aws configure
AWS Access Key ID [None]: AKIAIOSFODNN7EXAMPLE
AWS Secret Access Key [None]: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
Default region name [None]: us-west-2
Default output format [None]: json
```

## Installation On AWS
```bash
terraform init
terraform plan
terraform apply
```


Define region in provider.tf
```bash
provider "aws" {
  region = var.AWS_REGION
}
```

Define variables in vars.tf
```bash
variable "AWS_REGION" {
  default = "eu-central-1"
}

variable "AMI" {
    default = "ami-0d527b8c289b4af7f"
}
```

Create VPC in vpc.tf
```bash
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
```

Create 2 public and 2 private subnet
```bash
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
```

Create Internet Gateway
```bash
resource "aws_internet_gateway" "ec2-igw" {
  vpc_id = aws_vpc.ec2-vpc.id
  tags = {
    Name = "ec2-igw"
  }
}
```

Create route table and add public subnets to  route table
```bash
resource "aws_route_table" "ec2-public-crt" {
  vpc_id = aws_vpc.ec2-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ec2-igw.id
  }

  tags = {
    Name = "ec2-public-crt"
  }
}

resource "aws_route_table_association" "ec2-crta-public-subnet-1" {
  subnet_id      = aws_subnet.ec2-subnet-public-1.id
  route_table_id = aws_route_table.ec2-public-crt.id
}

resource "aws_route_table_association" "ec2-crta-public-subnet-2" {
  subnet_id      = aws_subnet.ec2-subnet-public-2.id
  route_table_id = aws_route_table.ec2-public-crt.id
}
```

Create route table and add private subnets to route table
```bash
resource "aws_route_table" "ec2-private-crt" {
  vpc_id = aws_vpc.ec2-vpc.id

  tags = {
    Name = "ec2-private-crt"
  }
}

resource "aws_route_table_association" "ec2-crta-private-subnet-1" {
  subnet_id      = aws_subnet.ec2-subnet-private-1.id
  route_table_id = aws_route_table.ec2-private-crt.id
}

resource "aws_route_table_association" "ec2-crta-private-subnet-2" {
  subnet_id      = aws_subnet.ec2-subnet-private-2.id
  route_table_id = aws_route_table.ec2-private-crt.id
}
```

Create Security Group

```bash
resource "aws_security_group" "ec2-sg" {
  vpc_id = aws_vpc.ec2-vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "ec2-sg"
  }
}

```