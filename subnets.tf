// creating of an public subnet

variable "own_public_subnet_cidr"{}

resource "aws_subnet" "public_subnet" {
depends_on=[aws_vpc.nishan_vpc]
  vpc_id     = aws_vpc.nishan_vpc.id
  cidr_block = var.own_public_subnet_cidr        
  map_public_ip_on_launch = "true"  
   availability_zone= var.own_public_subnet_availability_zone

   tags = {
    Name = "public_subnet"
  }
}

//  creation of an private subnet

variable "own_private_subnet_cidr"{}

resource "aws_subnet" "private_subnet" {
depends_on=[aws_vpc.nishan_vpc]
  vpc_id     = aws_vpc.nishan_vpc.id
  cidr_block = var.own_private_subnet_cidr

 availability_zone=var.own_private_subnet_availability_zone
  tags = {
    Name = "private_subnet"
  }
}

// creation of an route table for the public subnet 

resource "aws_route_table" "public_subnet_route_table" {
      depends_on=[aws_subnet.public_subnet]
      vpc_id = aws_vpc.nishan_vpc.id

route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gateway1.id
  }

tags = {
    Name = "public_subnet_route_table"
  }
}

// associating the route table with the public subnet 
 
resource "aws_route_table_association" "public_subnet_route_table_association" {
      depends_on=[aws_route_table.public_subnet_route_table]
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_subnet_route_table.id
}


variable "own_public_subnet_availability_zone"{}


//  creating the security group for public subnet 



resource "aws_security_group" "allow_public_web" {
    depends_on=[aws_subnet.public_subnet]
  name        = "allow_http_ssh_ping"
  description = "Allow ssh ping http inbound traffic"
  vpc_id      =  aws_vpc.nishan_vpc.id



  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
   
    ipv6_cidr_blocks  = ["::/0"]
  }



  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks   = ["::/0"]
  }
    
    
ingress {
    description = "icmp from VPC"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks =  ["::/0"]
  }



  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks =  ["::/0"]
  }



  tags = {
    Name = "allow_http_ssh_ping"
  }
}



//  bastion security group for allowing only ssh



resource "aws_security_group" "only_ssh_bositon" {
  depends_on=[aws_subnet.public_subnet]
  name        = "only_ssh_bositon"
  description = "Allow ssh bositon inbound traffic"
  vpc_id      =  aws_vpc.nishan_vpc.id




 ingress {
    description = "Only ssh_basiton in public subnet"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks =  ["::/0"]
  }



 
 egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks =  ["::/0"]
  }



  tags = {
    Name = "only_ssh_bositon"
  }
}




resource "aws_security_group" "only_sql_web" {
    depends_on=[aws_subnet.public_subnet]
  name        = "only_sql_web"
  description = "Allow only sql web inbound traffic"
  vpc_id      =  aws_vpc.nishan_vpc.id




 ingress {
    description = "Only web sql access from public subnet"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups=[aws_security_group.allow_public_web.id]
    
  }



  ingress {
    description = "Only web ping sql from public subnet"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    security_groups=[aws_security_group.allow_public_web.id]
    ipv6_cidr_blocks=["::/0"]
    
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks =  ["::/0"]
  }
     
     tags{
         Name= "only_sql_web"
     }


}




variable "own_private_subnet_availability_zone"{}


  //  creating the allow bastion host to ssh sql



 resource "aws_security_group" "only_ssh_sql_bositon" {
    depends_on=[aws_subnet.public_subnet]
  name        = "only_ssh_sql_bositon"
  description = "allow ssh bositon inbound traffic"
  vpc_id      =  aws_vpc.nishan_vpc.id




 ingress {
    description = "Only ssh_sql_bositon in public subnet"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups=[aws_security_group.only_ssh_bositon.id]
 
 }



 egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks =  ["::/0"]
  }



  tags = {
    Name = "only_ssh_sql_bositon"
  }
}





//  allocation of the EIP from the AMAZON pool of IPV4

resource "aws_eip" "nishan_ip" {

  vpc              = true
  public_ipv4_pool = "amazon"
}

output "new_output" {



     value=  aws_eip.nishan_ip
}

// creation of nat gateway in public subnet

resource "aws_nat_gateway" "nishanngw" {
    depends_on=[aws_eip.nishan_ip]
  allocation_id = aws_eip.nishan_ip.id
  subnet_id     = aws_subnet.public_subnet.id
tags = {
    Name = "nishanngw"
  }
}

// Route table for SNAT in private subnet

resource "aws_route_table" "private_subnet_route_table" {
      depends_on=[aws_nat_gateway.nishanngw]
  vpc_id = aws_vpc.nishan_vpc.id


  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.nishanngw.id
  }


/*route {
    ipv6_cidr_block        = "::/0"
    egress_only_gateway_id = "${aws_egress_only_internet_gateway.foo.id}"
}*/


  tags = {
    Name = "private_subnet_route_table"
  }
}

//  association of my route to the private subnet

resource "aws_route_table_association" "private_subnet_route_table_association" {
  depends_on = [aws_route_table.private_subnet_route_table]
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_subnet_route_table.id
}
