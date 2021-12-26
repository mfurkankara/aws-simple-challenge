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

resource "aws_route_table" "ec2-private-crt" {
  vpc_id = aws_vpc.ec2-vpc.id

  tags = {
    Name = "ec2-private-crt"
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

resource "aws_route_table_association" "ec2-crta-private-subnet-1" {
  subnet_id      = aws_subnet.ec2-subnet-private-1.id
  route_table_id = aws_route_table.ec2-private-crt.id
}

resource "aws_route_table_association" "ec2-crta-private-subnet-2" {
  subnet_id      = aws_subnet.ec2-subnet-private-2.id
  route_table_id = aws_route_table.ec2-private-crt.id
}

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

# resource "aws_elb" "ec2-elb" {
#   name               = "ec2-asg-elb"
#   security_groups    = [aws_security_group.elb-sg.id]
#   availability_zones = data.aws_availability_zones.all.names

#   health_check {
#     target              = "HTTP:${var.server_port}/"
#     interval            = 30
#     timeout             = 3
#     healthy_threshold   = 2
#     unhealthy_threshold = 2
#   }

#   # Adding a listener for incoming HTTP requests.
#   listener {
#     lb_port           = var.elb_port
#     lb_protocol       = "http"
#     instance_port     = var.server_port
#     instance_protocol = "http"
#   }
# }


# resource "aws_instance" "flask" {
#     ami = "${lookup(var.AMI, var.AWS_REGION)}"
#     instance_type = "t2.micro"
#     # VPC
#     subnet_id = "${aws_subnet.ec2-subnet-public-1.id}"
#     # Security Group
#     vpc_security_group_ids = ["${aws_security_group.ec2-sg.id}"]
#     # the Public SSH key
#     key_name = "${aws_key_pair.london-region-key-pair.id}"
#     # nginx installation
#     provisioner "file" {
#         source = "nginx.sh"
#         destination = "/tmp/nginx.sh"
#     }
#     provisioner "remote-exec" {
#         inline = [
#              "chmod +x /tmp/nginx.sh",
#              "sudo /tmp/nginx.sh"
#         ]
#     }
#     connection {
#         user = "${var.EC2_USER}"
#         private_key = "${file("${var.PRIVATE_KEY_PATH}")}"
#     }
# }
# // Sends your public key to the instance
# resource "aws_key_pair" "london-region-key-pair" {
#     key_name = "london-region-key-pair"
#     public_key = "${file(var.PUBLIC_KEY_PATH)}"
# }
