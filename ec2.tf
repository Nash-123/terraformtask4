variable "own_key_name"{}

variable "own_public_instance_ami"{}
variable "own_public_instance_type"{}
resource "aws_instance" "public_web" {
  depends_on=[aws_security_group.allow_public_web]
  ami           = var.own_public_instance_ami      
  instance_type = var.own_public_instance_type
  subnet_id= aws_subnet.public_subnet.id 
  vpc_security_group_ids=[ aws_security_group.allow_public_web.id ]
  
  key_name=var.own_key_name
  tags = {
    Name = "public_web"
  }
}

variable "own_bositon_instance_ami"{}
variable "own_bositon_instance_type"{}
resource "aws_instance" "bositon_host" {
depends_on=[aws_security_group.only_ssh_bositon]
  ami           = var.own_bositon_instance_ami
  instance_type = var.own_bositon_instance_type
  subnet_id= aws_subnet.public_subnet.id 
  vpc_security_group_ids=[ aws_security_group.only_ssh_bositon.id]
  key_name=var.own_key_name
  tags = {
    Name = "bositon_host"
  }
}
 
variable "own_private_instance_type"{}
variable "own_private_instance_ami"{}
resource "aws_instance" "my_sql" {
depends_on=[aws_security_group.only_sql_web,aws_security_group.only_ssh_sql_bositon]
  ami           = var.own_private_instance_ami   
  instance_type = var.own_private_instance_type
  subnet_id= aws_subnet.private_subnet.id 
  vpc_security_group_ids=[ aws_security_group.only_sql_web.id ,aws_security_group.only_ssh_sql_bositon.id]
  key_name=var.own_key_name
  tags = {
    Name = "my_sql"
  }
}
