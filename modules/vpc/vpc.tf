resource "aws_vpc" "this" {
cidr_block = var.vpc_cidr_block
enable_dns_support = true
enable_dns_hostnames = true


tags = {
Name = var.vpc_name
}
}


resource "aws_internet_gateway" "this" {
vpc_id = aws_vpc.this.id
tags = { Name = "${var.vpc_name}-igw" }
}


# Build maps idx->cidr to preserve order and map to AZs
locals {
public_map = { for idx, cidr in var.public_subnets : tostring(idx) => cidr }
private_map = { for idx, cidr in var.private_subnets : tostring(idx) => cidr }
}


resource "aws_subnet" "public" {
for_each = local.public_map
vpc_id = aws_vpc.this.id
cidr_block = each.value
availability_zone = var.availability_zones[tonumber(each.key)]
map_public_ip_on_launch = true
tags = {
Name = "${var.vpc_name}-public-${each.key}"
Tier = "public"
}
}


resource "aws_subnet" "private" {
for_each = local.private_map
vpc_id = aws_vpc.this.id
cidr_block = each.value
availability_zone = var.availability_zones[tonumber(each.key)]
map_public_ip_on_launch = false
tags = {
Name = "${var.vpc_name}-private-${each.key}"
Tier = "private"
}
}