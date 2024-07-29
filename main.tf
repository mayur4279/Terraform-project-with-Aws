resource "aws_vpc" "main" {
 cidr_block = "10.0.0.0/16"
 tags = {
   Name = "myvpc"
 }
}  

#basically we are created VPC with lot of range.  
#withing the vpc range you are taking the small area and creating a small range called subnet.   



resource  "aws_subnet" "sub-1"  {                  #subnet 1  
   vpc_id =  aws_vpc.main.id  
   cidr_block = "10.0.0.0/24"
   availability_zone = "us-east-1a" 
   map_public_ip_on_launch = true

}

resource  "aws_subnet" "sub-2"  {                 # subnet 2 
   vpc_id =  aws_vpc.main.id  
   cidr_block = "10.0.1.0/24"
   availability_zone = "us-east-1a" 
   map_public_ip_on_launch = true
   
}


resource "aws_internet_gateway" "igw" {          #internet gateway 
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "internet-gateway"
  }
} 


resource "aws_route_table" "rt" {                     #route table  
  vpc_id = aws_vpc.example.id     

  route {
    cidr_block = "10.0.1.0/24"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "internet_gateway"
  }
}


resource "aws_route_table_association" "a" {          #subnet association for subnet 1  to route table 
  subnet_id      = aws_subnet.sub-1.id
  route_table_id = aws_route_table.rt.id   
}

resource "aws_route_table_association" "b" {         #subnet association for subnet 2  to route table 
  subnet_id      = aws_subnet.sub-2.id
  route_table_id = aws_route_table.rt.id  
}



