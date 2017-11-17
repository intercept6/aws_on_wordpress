provider "aws" {
	region = "ap-northeast-1"
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
#	ingress {
#		from_port = "443"
#		to_port = "443"
#		protocol = "tcp"
#		ipv6_cidr_blocks = ["${var.myIP["ipv6"]}"]
#	}
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
