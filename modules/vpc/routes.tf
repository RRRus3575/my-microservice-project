# Single NAT Gateway (cost-conscious). For HA, create one per AZ.
resource "aws_eip" "nat" {
domain = "vpc"
tags = { Name = "${var.vpc_name}-nat-eip" }
}


resource "aws_nat_gateway" "this" {
allocation_id = aws_eip.nat.id
subnet_id = aws_subnet.public["0"].id # place NAT in first public subnet
tags = { Name = "${var.vpc_name}-nat" }
depends_on = [aws_internet_gateway.this]
}


# Public route table (shared by all public subnets)
resource "aws_route_table" "public" {
vpc_id = aws_vpc.this.id
route {
cidr_block = "0.0.0.0/0"
gateway_id = aws_internet_gateway.this.id
}
tags = { Name = "${var.vpc_name}-public-rt" }
}


resource "aws_route_table_association" "public_assoc" {
for_each = aws_subnet.public
subnet_id = each.value.id
route_table_id = aws_route_table.public.id
}


# Private route table (shared by all private subnets)
resource "aws_route_table" "private" {
vpc_id = aws_vpc.this.id
route {
cidr_block = "0.0.0.0/0"
nat_gateway_id = aws_nat_gateway.this.id
}
tags = { Name = "${var.vpc_name}-private-rt" }
}


resource "aws_route_table_association" "private_assoc" {
for_each = aws_subnet.private
subnet_id = each.value.id
route_table_id = aws_route_table.private.id
}