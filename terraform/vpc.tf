provider "aws" {
	region = "ap-northeast-1"
}

# VPC
resource "aws_vpc" "wpVPC" {
	cidr_block = "10.0.0.0/16"
	assign_generated_ipv6_cidr_block = "true"
	instance_tenancy = "default"
	enable_dns_support = "true"
	enable_dns_hostnames = "true"
	tags {
		Name = "wpVPC"
		Project = "wordpress"
	}
}

# InternetGateway
resource "aws_internet_gateway" "wpGW" {
	vpc_id = "${aws_vpc.wpVPC.id}"
	tags {
		Name = "wpGW"
		Project = "wordpress"
	}
}

# Subnet
## Public
resource "aws_subnet" "wpSubnet_public_a" {
	vpc_id = "${aws_vpc.wpVPC.id}"
	cidr_block = "10.0.0.0/24"
	ipv6_cidr_block = "${cidrsubnet(aws_vpc.wpVPC.ipv6_cidr_block, 8, 0)}"
	assign_ipv6_address_on_creation = "true"
	availability_zone = "ap-northeast-1a"
	tags {
		Name = "wpSubnet_public_a"
		Project = "wordpress"
	}
}
resource "aws_subnet" "wpSubnet_public_c" {
	vpc_id = "${aws_vpc.wpVPC.id}"
	cidr_block = "10.0.1.0/24"
	ipv6_cidr_block = "${cidrsubnet(aws_vpc.wpVPC.ipv6_cidr_block, 8, 1)}"
	assign_ipv6_address_on_creation = "true"
	availability_zone = "ap-northeast-1c"
	tags {
		Name = "wpSubnet_public_c"
		Project = "wordpress"
	}
}
## Private
resource "aws_subnet" "wpSubnet_private_a" {
	vpc_id = "${aws_vpc.wpVPC.id}"
	cidr_block = "10.0.10.0/24"
	availability_zone = "ap-northeast-1a"
	tags {
		Name = "wpSubnet_private_a"
		Project = "wordpress"
	}
}
resource "aws_subnet" "wpSubnet_private_c" {
	vpc_id = "${aws_vpc.wpVPC.id}"
	cidr_block = "10.0.11.0/24"
	availability_zone = "ap-northeast-1c"
	tags {
		Name = "wpSubnet_private_c"
		Project = "wordpress"
	}
}
