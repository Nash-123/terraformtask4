variable "vpc_cidr"{
    default="192.168.0.0/16" 
}
variable "public_subnet_cidr"{
    default="192.168.0.0/24" 
}
variable "private_subnet_cidr"{
   default="192.168.1.0/24" 
}
variable "public_subnet_availability_zone"{
   default="ap-south-1a"
}
variable "private_subnet_availability_zone"{
    default="ap-south-1b"
}
variable "key_name"{
     default= "my_vpc_1"
}

variable "public_instance_ami"{
     default="ami-0d2d7c48d5f1e9705"
}
variable "public_instance_type"{
    default="t2.micro"
}
variable "private_instance_ami"{
   default="ami-072929a40b1e48bbe"
}
variable "private_instance_type"{
   default="t2.micro"
}
variable "bositon_instance_ami"{
    default="ami-052c08d70def0ac62"
}
variable "bositon_instance_type"{
    default="t2.micro"
}
