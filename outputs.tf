# Instance-a
output "Instance-a Address" {
	value = "${aws_instance.wpInstance-a.public_ip}"
}
output "Instance-a IPv6 Address" {
	value = "${aws_instance.wpInstance-a.ipv6_addresses}"
}

# Instance-c
output "Instance-c IPv4 Address" {
	value = "${aws_instance.wpInstance-c.public_ip}"
}
output "Instance-c IPv6 Address" {
	value = "${aws_instance.wpInstance-c.ipv6_addresses}"
}

# RDS Instance
output "rds_endpoint" {
    value = "${aws_db_instance.wpDbinstance.address}"
}

# DNS Name
output "URL" {
	value = "https://${var.dns["sub-domain"]}.${var.dns["domain"]}"
}
