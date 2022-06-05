# Define the provider
provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

data "aws_ami" "ami-amzn2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}


data "aws_vpc" "default" {
  default = true
}

resource "aws_default_subnet" "default" {
  availability_zone = "us-east-1a"
  tags = {
    Name = "Default subnet for us-east-1"
  }
}

resource "aws_instance" "vm" {
  ami                    = data.aws_ami.ami-amzn2.id
  key_name               = aws_key_pair.key.key_name
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.sg.id]
  user_data = "${file("http.sh")}"
  tags = {
    Name = "EC2"
    }
}

resource "aws_security_group" "sg" {
  name        = "allow_http"
  description = "Allow http inbound traffic"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description      = "Http"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
   ingress {
    description      = "Http"
    from_port        = 8081
    to_port          = 8081
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    description      = "ssh"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  tags = {
    Name = "allow_http"
  }
}

# Adding SSH key to Amazon EC2
resource "aws_key_pair" "key" {
  key_name   = "key"
  public_key = file("key.pub")
}

resource "aws_ecr_repository" "assig1" {
  name                 = "assig1"
  image_tag_mutability = "MUTABLE"
}