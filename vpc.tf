variable "own_vpc_cidr"{}
resource "aws_vpc" "nishan_vpc" {
  cidr_block       =  var.own_vpc_cidr
  instance_tenancy = "default"
  enable_dns_hostnames = true
  tags = {


    Name = "nishan_vpc"
    
  }
}
resource "aws_internet_gateway" "gateway1" {
  depends_on=[aws_vpc.nishan_vpc]
  vpc_id = aws_vpc.nishan_vpc.id


  tags = {
    Name = "gateway1"
  }
}
