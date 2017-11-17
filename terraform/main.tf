provider "aws" {
	region = "ap-northeast-1"
}

# Certificate Manager
data "aws_acm_certificate" "wpCertificatemanager" {
	domain   = "*.${var.dns["domain"]}"
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
