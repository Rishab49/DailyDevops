terraform{
    required_provider{
        aws = {
            source = "hashicorp/aws"
        }
    }


    backend "s3" {
    region = "us-east-1"
    bucket = "rajrishab-challenge2"
    key = "state" 
}

}
resource "aws_vpc" "main"{
    cidr_block = "10.0.0.0/16"
}



resource "aws_subnet" "subnet1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "tf-example"
  }
}

resource "aws_instance" "instance1"{
    ami = "ami-068c0051b15cdb816"
    instance_type = "t2.micro"
    subnet_id = aws_subnet.subnet1.id
    vpc_security_group_ids = [aws_security_group.SG1.id]
    user_data = << EOF
    sudo dnf update -y
    sudo dnf install docker
    cat << CONF > prom.yaml
    global:
        scrape_interval: 15s # How often to scrape targets by default
        evaluation_interval: 15s
    

    scrape_configs:
        - job_name: 'prometheus' # Job to scrape Prometheus's own metrics
            static_configs:
            - targets: ['localhost:9090'] 
    
    CONF
    docker run -d \
    --name my-prometheus \
    -p 9090:9090 \
    -v prometheus-data:/prometheus \
    -v "$(pwd)"/prometheus.yml:/etc/prometheus/prometheus.yml \
    prom/prometheus
    EOF
}


resource "aws_security_group" "SG1"{

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


resource "aws_internet_gateway" "ig"{
    vpc_id = aws_vpc.main.id

    tags = {
        Name = "IGW1"
    }
}

resource "aws_route_table" "route_table"{
    vpc_id = aws_vpc.main.id

    route{
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.ig.id
    }


    route{
        cidr_block = "10.0.0.0/16"
        gateway_id = "local"
    }


    tags = {
        Name = "RT1"
    }
}

resource "aws_route_table_association" "route_table_association" {
  subnet_id      = aws_subnet.subnet_id.id
  route_table_id = aws_route_table.route_table.id
}


