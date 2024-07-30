#VPC creation 

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "myvpc"
  }
}

#basically we are created VPC with lot of range.  
#withing that vpc range you are taking the small area and creating a small range called subnets.   

#subnet-1 creation 

resource "aws_subnet" "sub-1" {
  vpc_id                  = aws_vpc.main.id
  availability_zone       = "us-east-1a"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "my_subnet-1"
  }
}


#subnet-2 creation   

resource "aws_subnet" "sub-2" {
  vpc_id                  = aws_vpc.main.id
  availability_zone       = "us-east-1b"
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "my_subnet-2"
  }
}


#internet_gateway creation  

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "my_gateway"
  }
}


#route table  creation  

resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "route_table"
  }
}


#Assigning route table to subnet-1 

resource "aws_route_table_association" "sub1-association" {
  subnet_id      = aws_subnet.sub-1.id
  route_table_id = aws_route_table.my_route_table.id
}


#Assigning route table to subnet-2 

resource "aws_route_table_association" "sub2-association" {
  subnet_id      = aws_subnet.sub-2.id
  route_table_id = aws_route_table.my_route_table.id
}



#creating security group for main servers 

resource "aws_security_group" "main_security_group" {
  vpc_id = aws_vpc.main.id

  ingress {

    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "used for ssh port"

  }

  ingress {

    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }

  tags = {
    Name = "Main_server"
  }
}


#Creating instance-1 with user data script 

resource "aws_instance" "main_server-1" {
  ami                    = "ami-0427090fd1714168b"
  instance_type          = "t2.micro"
  key_name               = "netflixapp"
  subnet_id              = aws_subnet.sub-1.id
  vpc_security_group_ids = [aws_security_group.main_security_group.id]
  user_data              = base64encode(file("server1-userdata.sh"))
  tags = {
    Name = "main_server-1"
  }
}



#Creating instance-2 with user data script 

resource "aws_instance" "main_server-2" {
  ami                    = "ami-0427090fd1714168b"
  instance_type          = "t2.micro"
  key_name               = "netflixapp"
  subnet_id              = aws_subnet.sub-2.id
  vpc_security_group_ids = [aws_security_group.main_security_group.id]
  user_data              = base64encode(file("server2-userdata.sh"))
  tags = {
    Name = "main_server-2"
  }
}


#Creating instance-3 with user data script 

resource "aws_instance" "main_server-3" {
  ami                    = "ami-0427090fd1714168b"
  instance_type          = "t2.micro"
  key_name               = "netflixapp"
  subnet_id              = aws_subnet.sub-2.id
  vpc_security_group_ids = [aws_security_group.main_security_group.id]
  user_data              = base64encode(file("server3-userdata.sh"))
  tags = {
    Name = "main_server-3"
  }
}


#Creating Load balancer  

resource "aws_lb" "mylb" {
  load_balancer_type = "application"
  security_groups    = [aws_security_group.main_security_group.id]
  internal           = false
  subnets            = [aws_subnet.sub-1.id, aws_subnet.sub-2.id]
  tags = {
    Name = "my_load_balancer"
  }
}


#creating target group  

resource "aws_lb_target_group" "my_target_group" {
  target_type     = "instance"
  vpc_id          = aws_vpc.main.id
  protocol        = "HTTP"
  port            = 80
  ip_address_type = "ipv4"
  health_check {
    protocol = "HTTP"
    path     = "/"
  }
  tags = {
    Name = "my_group"
  }
}


#Assigining all three instnaces into target group  

resource "aws_lb_target_group_attachment" "test-1" {
  target_group_arn = aws_lb_target_group.my_target_group.arn
  target_id        = aws_instance.main_server-1.id
  port             = 80
}
resource "aws_lb_target_group_attachment" "test-2" {
  target_group_arn = aws_lb_target_group.my_target_group.arn
  target_id        = aws_instance.main_server-2.id
  port             = 80
}
resource "aws_lb_target_group_attachment" "test-3" {
  target_group_arn = aws_lb_target_group.my_target_group.arn
  target_id        = aws_instance.main_server-3.id
  port             = 80
}



#Assigining load balancer to target group 

resource "aws_lb_listener" "frontend" {
  load_balancer_arn = aws_lb.mylb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my_target_group.arn

  }
}


#Viewing dns in terminal  

output "load-balancer-dns" {
  value = aws_lb.mylb.dns_name
}

#Viewing Instance IP's in terminal  

output "main_server-1-ip" {
  description = "ip address_of_main_server_1"
  value       = aws_instance.main_server-1.public_ip
}

output "main_server-2-ip" {
  description = "ip address_of_main_server_2"
  value       = aws_instance.main_server-2.public_ip
}


output "main_server-3-ip" {
  description = "ip address_of_main_server_3"
  value       = aws_instance.main_server-3.public_ip
}

