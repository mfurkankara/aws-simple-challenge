
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


Create configuring_ec2.sh for user_data (Docker swarm and nginx installation and proxy flask container)
```bash

#!/bin/sh
sudo apt update -y

sudo apt install nginx -y 
echo "server {
    listen 80;
    server_name _;
    location /myflaskapp {
        proxy_pass http://localhost:5000/;
        }
    }" >> server
sudo rm /etc/nginx-sites-enabled/default
sudo nginx -t
sudo nginx -s reload

sudo mv server /etc/nginx/sites-enabled/
sudo chown root:root /etc/nginx/sites-enabled/server


sudo apt install -y docker.io
sudo usermod -a -G docker ubuntu
sudo docker swarm init

sudo docker service create --name flask --publish published=5000,target=5000 mfurkankara/flask:1

```


Create ec2 instance in Auto Scaling Group with Application Load Balancer 

```bash
resource "aws_launch_configuration" "ec2-conf" {
  name          = "ec2-config"
  image_id      = var.AMI
  instance_type = "t2.micro"
  
  key_name = "ec2"
  user_data = "${file("configuring_ec2.sh")}"

  security_groups = ["${aws_security_group.ec2-sg.id}"]
}


resource "aws_autoscaling_group" "ec2-asg" {
  name                 = "ec2-asg-config"
  launch_configuration = aws_launch_configuration.ec2-conf.name
  min_size             = 1
  max_size             = 1

#   load_balancers    = [aws_elb.ec2-elb.name]
#   health_check_type = "ELB"

  vpc_zone_identifier = ["${aws_subnet.ec2-subnet-public-1.id}"]
}


resource "aws_alb" "ec2-alb" {
  name            = "ec2-alb"
  security_groups = ["${aws_security_group.ec2-sg.id}"]
  subnets         = ["${aws_subnet.ec2-subnet-public-1.id}","${aws_subnet.ec2-subnet-public-2.id}"]
  tags = {
    Name = "ec2-alb"
  }
}

resource "aws_alb_target_group" "ec2-alb-target" {
  name     = "ec2-alb-target"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.ec2-vpc.id}"
  health_check {
    path = "/"
    port = 80
  }
}

resource "aws_alb_listener" "listener_http" {
  load_balancer_arn = "${aws_alb.ec2-alb.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.ec2-alb-target.arn}"
    type             = "forward"
  }
}

```