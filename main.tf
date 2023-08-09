//  create VPC

resource "aws_vpc" "first-vpc" {
  cidr_block = "10.10.0.0/16"
}

//  create Subnet

resource "aws_subnet" "first-subnet" {
  vpc_id     = aws_vpc.first-vpc.id
  cidr_block = "10.10.1.0/24"

  tags = {
    Name = "subnet"
  }
}

//  create Internet Gateway

resource "aws_internet_gateway" "first-igw" {
  vpc_id = aws_vpc.first-vpc.id

  tags = {
    Name = "Internet Gateway"
  }
}

//  create route table

resource "aws_route_table" "first-rt" {
  vpc_id = aws_vpc.first-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.first-igw.id
  }


  tags = {
    Name = "route table"
  }
}

//  create associate subnet with route table

resource "aws_route_table_association" "first-rta" {
  subnet_id      = aws_subnet.first-subnet.id
  route_table_id = aws_route_table.first-rt.id
}

//  create security group

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.first-vpc.id

  dynamic "ingress" {
    for_each = var.ports
    iterator = port
    content {
      description      = "TLS from VPC"
      from_port        = port.value
      to_port          = port.value
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]

    }
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}

//  create EC2 instance

resource "aws_instance" "first-instance" {
  ami                    = "ami-0f5ee92e2d63afc18"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.first-subnet.id
  vpc_security_group_ids = [aws_security_group.allow_tls.id]

  tags = {
    Name = "First-terraform-instance"
  }

}

