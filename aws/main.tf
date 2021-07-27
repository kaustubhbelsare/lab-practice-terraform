provider "aws" {
 region = "us-east-2"
}

variable "server" {
  type = string
}
data "aws_ami" "latest-os" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"] # Amazon
}

data "aws_vpc" "myvpc" {
    filter {
    name   = "tag:Name"
    values = ["Defa*"]
  }
}

output "VPC_ID" {
 value = data.aws_vpc.myvpc.id
}

data "aws_subnet" "pri-subnet" {
  vpc_id = data.aws_vpc.myvpc.id
  filter {
    name   = "tag:Name"
    values = ["pri*"]
  }
}

output "Private_Subnet" {
 value = data.aws_subnet.pri-subnet.id
}

data "aws_subnet" "pub-subnet" {
  vpc_id = data.aws_vpc.myvpc.id
  filter {
    name   = "tag:Name"
    values = ["pub*"]
  }
}

output "Public_Subnet" {
 value = data.aws_subnet.pub-subnet.id
}

resource "aws_instance" "s1" {
 ami = data.aws_ami.latest-os.id
 instance_type = "t2.micro"
 subnet_id = "${var.server == "web" ? data.aws_subnet.pub-subnet.id : data.aws_subnet.pri-subnet.id }"
  tags = {
    Name = "Instance1"
    Env = "Prod"
  }
}