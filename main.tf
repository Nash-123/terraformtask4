provider "aws" {
    region= "ap-south-1"
    profile= "nishan"
}
module "aws_vpc"{


    source="./aws"
    own_vpc_cidr=var.vpc_cidr
    own_public_subnet_cidr=var.public_subnet_cidr
    own_private_subnet_cidr=var.private_subnet_cidr
    own_public_subnet_availability_zone=var.public_subnet_availability_zone
    own_private_subnet_availability_zone=var.private_subnet_availability_zone
    own_key_name=var.key_name
    own_public_instance_ami=var.public_instance_ami
    own_public_instance_type=var.public_instance_type
    own_private_instance_ami=var.private_instance_ami
    own_private_instance_type=var.private_instance_type
    own_bositon_instance_ami=var.bositon_instance_ami
    own_bositon_instance_type=var.bositon_instance_type
}
