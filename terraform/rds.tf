provider "aws" {
	region = "ap-northeast-1"
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
