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

# SecurityGroup
## public
resource "aws_security_group" "wpSecurityGroup_public" {
	name = "wpSecurityGroup_public"
	description = "wpSecurityGroup_public"
	vpc_id = "${aws_vpc.wpVPC.id}"
	ingress {
		from_port = "80"
		to_port = "80"
		protocol = "tcp"
		security_groups = ["${aws_security_group.wpSecurityGroup-alb.id}"]
	}
	ingress {
		from_port = "22"
		to_port = "22"
		protocol = "tcp"
		ipv6_cidr_blocks = ["${var.myIP["ipv6"]}"]
	}
	ingress {
		from_port = "443"
		to_port = "443"
		protocol = "tcp"
		ipv6_cidr_blocks = ["${var.myIP["ipv6"]}"]
	}
	egress {
		from_port = 0
		to_port = 0
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]
		ipv6_cidr_blocks = ["::/0"]
	}
	tags {
		Name = "wpSecurityGroup_public"
		Project = "wordpress"
	}
}
## private
resource "aws_security_group" "wpSecurityGroup_private" {
	name = "wpSecurityGroup_private"
	description = "wpSecurityGroup_private"
	vpc_id = "${aws_vpc.wpVPC.id}"
	ingress {
		from_port = 3306
		to_port = 3306
		protocol = "tcp"
		security_groups = ["${aws_security_group.wpSecurityGroup_public.id}"]
	}
	egress {
		from_port = 0
		to_port = 0
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}
	tags {
		Name = "wpSecurityGroup_private"
		Project = "wordpress"
	}
}
## alb
resource "aws_security_group" "wpSecurityGroup-alb" {
	name = "wpSecurityGroup-alb"
	description = "wpSecurityGroup-alb"
	vpc_id = "${aws_vpc.wpVPC.id}"
	ingress {
		from_port = 443
		to_port = 443
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
		ipv6_cidr_blocks = ["::/0"]
	}
	egress {
		from_port = 0
		to_port = 0
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}
	tags {
		Name = "wpSecurityGroup-alb"
		Project = "wordpress"
	}
}

# Instance
## Instance_a
resource "aws_instance" "wpInstance_a" {
	ami = "${var.images["ap-northeast-1"]}"
	instance_type = "t2.nano"
	key_name = "arata001"
	user_data = "${file("userdata.sh")}"
	vpc_security_group_ids = [
		"${aws_security_group.wpSecurityGroup_public.id}"
	]
	subnet_id = "${aws_subnet.wpSubnet_public_a.id}"
	associate_public_ip_address = "true"
	ipv6_address_count = "1"
	root_block_device = {
		volume_type = "gp2"
		volume_size = "16"
	}
	tags {
		Name = "wpInstance_a"
		Project = "wordpress"
	}
}
## Instance_c
resource "aws_instance" "wpInstance_c" {
	ami = "${var.images["ap-northeast-1"]}"
	instance_type = "t2.nano"
	key_name = "arata001"
	user_data = "${file("userdata.sh")}"
	vpc_security_group_ids = [
		"${aws_security_group.wpSecurityGroup_public.id}"
	]
	subnet_id = "${aws_subnet.wpSubnet_public_c.id}"
	associate_public_ip_address = "true"
	ipv6_address_count = "1"
	root_block_device = {
		volume_type = "gp2"
		volume_size = "16"
	}
	tags {
		Name = "wpInstance_c"
		Project = "wordpress"
	}
}

# DB Subnet Group
resource "aws_db_subnet_group" "wpDbsubnetgroup" {
	name = "wpdbsubnetgroup"
	subnet_ids = ["${aws_subnet.wpSubnet_private_a.id}", "${aws_subnet.wpSubnet_private_c.id}"]
	tags {
		Name = "wpDbsubnetgroup"
		Project = "wordpress"
	}
}

# DB Instance
resource "aws_db_instance" "wpDbinstance" {
	allocated_storage = 10
	storage_type = "gp2"
	engine = "mysql"
	engine_version = "5.6.35"
	instance_class = "db.t2.micro"
	name = "wpDbinstance"
	identifier = "wpdbinstance"
	username = "root"
	password = "password"
	db_subnet_group_name = "wpdbsubnetgroup"
	parameter_group_name = "default.mysql5.6"
	multi_az = "true"
	skip_final_snapshot = "true"
	vpc_security_group_ids = [ "${aws_security_group.wpSecurityGroup_private.id}"]
}

# Certificate Manager
data "aws_acm_certificate" "wpCertificatemanager" {
	domain   = "*.arata-fun.net"
}

# ELB
## Load Balancer
resource "aws_alb" "wpAlb" {
	name = "wpAlb"
	security_groups = ["${aws_security_group.wpSecurityGroup-alb.id}"]
	subnets = [ "${aws_subnet.wpSubnet_public_a.id}", "${aws_subnet.wpSubnet_public_c.id}"]
	tags {
		Name = "wpAlb"
		Project = "wordpress"
	}
}
## Target Group
resource "aws_alb_target_group" "wpAlbtargetgroup" {
	name = "wpAlbtargetgroup"
	port = "80"
	protocol = "HTTP"
	vpc_id = "${aws_vpc.wpVPC.id}"
	tags {
		Name = "wpAlbtargetgroup"
		Project = "wordpress"
	}
}
## Target Group Attachment
resource "aws_alb_target_group_attachment" "wpAlbtargetgroupattachement_a" {
	target_group_arn = "${aws_alb_target_group.wpAlbtargetgroup.arn}"
	target_id = "${aws_instance.wpInstance_a.id}"
  port = "80"
}
resource "aws_alb_target_group_attachment" "wpAlbtargetgroupattachement_c" {
	target_group_arn = "${aws_alb_target_group.wpAlbtargetgroup.arn}"
	target_id = "${aws_instance.wpInstance_c.id}"
  port = "80"
}
## Listener
resource "aws_alb_listener" "wpAlbListener" {
		load_balancer_arn = "${aws_alb.wpAlb.arn}"
		port = "443"
		protocol = "HTTPS"
		certificate_arn = "${data.aws_acm_certificate.wpCertificatemanager.arn}"
		default_action {
			target_group_arn = "${aws_alb_target_group.wpAlbtargetgroup.arn}"
			type = "forward"
		}
}

# Route53
data "aws_route53_zone" "wordpress" {
	name = "${var.dns["domain"]}."
}
resource "aws_route53_record" "wordpress" {
	zone_id = "${data.aws_route53_zone.wordpress.zone_id}"
	name = "${var.dns["sub-domain"]}.${var.dns["domain"]}"
	type = "A"
	alias {
		name = "${aws_alb.wpAlb.dns_name}"
		zone_id = "${aws_alb.wpAlb.zone_id}"
		evaluate_target_health = "true"
	}
}
