terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }

  backend "s3" {
    region = "us-east-2"
    bucket = "rajrishab-challenge4"
    key    = "state"
  }
}
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "subnet1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "subnet2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b" # Different AZ
  map_public_ip_on_launch = true
}


resource "aws_lb" "lb" {
  name               = "lb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.SG1.id]
  subnets            = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]
}


resource "aws_lb_target_group" "TG" {

  name     = "TG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path = "/health/"
  }
}


resource "aws_lb_listener" "LBListener" {
  load_balancer_arn = aws_lb.lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.TG.arn
  }
}

resource "aws_launch_template" "launch_template" {



  image_id      = "ami-068c0051b15cdb816"
  instance_type = "t2.micro"
  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.SG1.id]
  }
  update_default_version = true

  user_data = base64encode(<<EOF
#!/bin/bash
sudo dnf update -y
sudo dnf install -y docker
sudo dnf install git -y
sudo systemctl start docker
sudo systemctl enable docker

sudo git clone https://github.com/Rishab49/DailyDevops.git
cd DailyDevops/challenge4/python
sudo docker build -t challenge4 .
sudo docker run --name challenge4 -p 80:80 challenge4
EOF
  )
}


resource "aws_autoscaling_group" "ASG1" {
  name                = "ASG1"
  vpc_zone_identifier = [aws_subnet.subnet1.id,aws_subnet.subnet2.id]
  max_size            = 2
  min_size            = 1
  desired_capacity    = 1


  target_group_arns = [aws_lb_target_group.TG.arn]

  launch_template {
    id = aws_launch_template.launch_template.id
  }
}


resource "aws_security_group" "SG1" {

  name        = "example-security-group"
  description = "Allow HTTP and SSH access"
  vpc_id      = aws_vpc.main.id # Replace with your VPC ID or reference

  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Be more specific in production
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Be more specific in production
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Be more specific in production
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "example-sg"
  }

}

resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "IGW1"
  }
}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ig.id
  }
  route {
    cidr_block = "10.0.0.0/16"
    gateway_id = "local"
  }


  tags = {
    Name = "RT1"
  }
}


resource "aws_route_table_association" "route_table_association" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_route_table_association" "route_table_association2" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.route_table.id
}


