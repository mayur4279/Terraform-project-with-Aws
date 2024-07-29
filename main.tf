resource "aws_vpc" "main" {               #vpc 
 cidr_block = "10.0.0.0/16"
 tags = {
   Name = "myvpc"
 }
}  


#basically we are created VPC with lot of range.  
#withing that vpc range you are taking the small area and creating a small range called subnet.   


resource "aws_subnet" "sub1" {                 #subnet1  
  vpc_id =  aws_vpc.main.id  
  availability_zone = "us-east-1a"
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true 
  tags = {
    Name = "subnet-1"
  }
}  


resource "aws_subnet" "sub2" {                 #subnet2
  vpc_id =  aws_vpc.main.id  
  availability_zone = "us-east-1a"
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = true 
  tags =  {
    Name = "subnet-2"
  }
}

resource "aws_internet_gateway" "igw" {         #internet gateway  
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "my_gateway"  
  }
}

