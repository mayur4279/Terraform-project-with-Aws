resource "aws_vpc" "main" { #vpc 
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "myvpc"
  }
}


#basically we are created VPC with lot of range.  
#withing that vpc range you are taking the small area and creating a small range called subnet.   


resource "aws_subnet" "sub-1" { #public_subnet1  
  vpc_id                  = aws_vpc.main.id
  availability_zone       = "us-east-1a"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet"
  }
}


resource "aws_subnet" "sub-2" { #private_subnet  
  vpc_id                  = aws_vpc.main.id
  availability_zone       = "us-east-1b"
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = false
  tags = {
    Name = "private-subnet"
  }
}

resource "aws_internet_gateway" "igw" { #internet gateway  
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "my_gateway"
  }
}

resource "aws_route_table" "public_route" { #public route table    
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "route_table"
  }
}


resource "aws_route_table" "private_route" {        #private route table    
  vpc_id = aws_vpc.main.id

  route = []
  tags = {
    Name = "route_table"
  }
}


resource "aws_route_table_association" "making_public" {
  subnet_id      = aws_subnet.sub-1.id
  route_table_id = aws_route_table.public_route.id
}

resource "aws_route_table_association" "making_private" {
  subnet_id      = aws_subnet.sub-2.id
  route_table_id = aws_route_table.private_route.id
}



resource "aws_security_group" "created_security_group" { #creating security group  
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {

    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}


