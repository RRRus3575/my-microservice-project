variable "vpc_cidr_block" {
type = string
}


variable "public_subnets" {
type = list(string)
}


variable "private_subnets" {
type = list(string)
}


variable "availability_zones" {
description = "AZs matching the subnets by index"
type = list(string)
}


variable "vpc_name" {
type = string
}