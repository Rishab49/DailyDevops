terraform{

    required_providers{
        aws = {
            source = "hashicorp/aws"
        }
    }
    backend "s3"{
        region=""
        bucket="rajrishab-challenge5"
        key = "state"
    }
}


# vpc
resource "aws_vpc" "main"{
    cidr_block = "10.0.0.0/16"
    region = "us-east-1"
}

# 2 subnet
resource "aws_subnet" "subnet1" {
    vpc_id = aws_vpc.main.id
    availability_zone = "us-east-1a"
    cidr_block = "10.0.1.0/24"
    map_public_ip_on_launch = true
}


resource "aws_subnet" "subnet2"{
    vpc_id = aws_vpc.main.id
    availability_zone = "us-east-1b"
    cidr_block = "10.0.2.0/24"
    map_public_ip_on_launch = true
}



# sg
resource "aws_security_group" "sg1"{
    vpc_id = aws_vpc.main.id

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress{
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }


}


# ig
resource "aws_internet_gateway" "igw1"{
    vpc_id = aws_vpc.main.id
}

# route table
resource "aws_route_table" "rt1"{
    vpc_id = aws_vpc.main.id

    route{
        cidr_block = "10.0.0.0/16"
        gateway_id = "local"
    }

    route{
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw1.id
    }
}


resource "aws_route_table_association" "association1" {
  subnet_id = aws_subnet.subnet1.id
  route_table_id = aws_route_table.rt1.id
}


resource "aws_route_table_association" "association2" {
  subnet_id = aws_subnet.subnet2.id
  route_table_id = aws_route_table.rt1.id
}


#eks

module "eks"{
    source = "terraform-aws-modules/eks/aws"
    version = "~> 20.31"


    cluster_name = "mycluster"
    cluster_version = "20.31"


    eks_managed_node_groups = {
        group1 = {
            instance_types = ["t2.micro"]
            min_size = 1
            max_size = 3
            desired_size = 2
        }
    }


    vpc_id = aws_vpc.main.id
    subnet_ids = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]
}