provider "aws" {
	region = "ap-northeast-1"
}

# Instance
## Instance_a
resource "aws_instance" "wpInstance_a" {
	ami = "${var.images["ap-northeast-1"]}"
	instance_type = "t2.nano"
	key_name = "${var.key["name"]}"
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
	key_name = "${var.key["name"]}"
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
