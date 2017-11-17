provider "aws" {
	region = "ap-northeast-1"
}

# RouteTable
## Public
resource "aws_route_table" "wpRoute_public" {
	vpc_id = "${aws_vpc.wpVPC.id}"
	route {
		cidr_block = "0.0.0.0/0"
		gateway_id = "${aws_internet_gateway.wpGW.id}"
	}
	route {
		ipv6_cidr_block = "::/0"
		gateway_id = "${aws_internet_gateway.wpGW.id}"
	}
	tags {
		Name = "wpRoute_public"
		Project = "wordpress"
	}
}
resource "aws_route_table" "wpRoute_private" {
	vpc_id = "${aws_vpc.wpVPC.id}"
	tags {
		Name = "wpRoute_private"
		Project = "wordpress"
	}
}

# RouteTableAssociation
## Public
resource "aws_route_table_association" "wpRta_public_a" {
	subnet_id = "${aws_subnet.wpSubnet_public_a.id}"
	route_table_id = "${aws_route_table.wpRoute_public.id}"
}
resource "aws_route_table_association" "wpRta_public_c" {
	subnet_id = "${aws_subnet.wpSubnet_public_c.id}"
	route_table_id = "${aws_route_table.wpRoute_public.id}"
}
## Private
resource "aws_route_table_association" "wpRta_private_a" {
	subnet_id = "${aws_subnet.wpSubnet_private_a.id}"
	route_table_id = "${aws_route_table.wpRoute_private.id}"
}
resource "aws_route_table_association" "wpRta_private_c" {
	subnet_id = "${aws_subnet.wpSubnet_private_c.id}"
	route_table_id = "${aws_route_table.wpRoute_private.id}"
}
