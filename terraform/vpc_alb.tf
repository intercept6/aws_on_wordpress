provider "aws" {
	region = "ap-northeast-1"
}

# ALB
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
resource "aws_alb_target_group" "wpAlbDefaultTargetGroup" {
	name = "wpAlbDefaultTargetGroup"
	port = "80"
	protocol = "HTTP"
	vpc_id = "${aws_vpc.wpVPC.id}"
	tags {
		Name = "wpAlbDefaultTargetGroup"
		Project = "wordpress"
	}
}
resource "aws_alb_target_group" "wpAlbMasterTargetGroup" {
	name = "wpAlbMasterTargetGroup"
	port = "80"
	protocol = "HTTP"
	vpc_id = "${aws_vpc.wpVPC.id}"
	tags {
		Name = "wpAlbMasterTargetGroup"
		Project = "wordpress"
	}
}
## Target Group Attachment
resource "aws_alb_target_group_attachment" "wpAlbDefaultTargetGroupattachement_a" {
	target_group_arn = "${aws_alb_target_group.wpAlbDefaultTargetGroup.arn}"
	target_id = "${aws_instance.wpInstance_a.id}"
  port = "80"
}
resource "aws_alb_target_group_attachment" "wpAlbDefaultTargetGroupattachement_c" {
	target_group_arn = "${aws_alb_target_group.wpAlbDefaultTargetGroup.arn}"
	target_id = "${aws_instance.wpInstance_c.id}"
  port = "80"
}
resource "aws_alb_target_group_attachment" "wpAlbMasterTargetGroupattachement_a" {
	target_group_arn = "${aws_alb_target_group.wpAlbMasterTargetGroup.arn}"
	target_id = "${aws_instance.wpInstance_a.id}"
  port = "80"
}
## Listener
resource "aws_alb_listener" "wpAlbListener" {
		load_balancer_arn = "${aws_alb.wpAlb.arn}"
		port = "443"
		protocol = "HTTPS"
		certificate_arn = "${data.aws_acm_certificate.wpCertificatemanager.arn}"
		default_action {
			target_group_arn = "${aws_alb_target_group.wpAlbDefaultTargetGroup.arn}"
			type = "forward"
		}
}
resource "aws_alb_listener_rule" "wp-admin" {
  listener_arn = "${aws_alb_listener.wpAlbListener.arn}"
  priority     = 1
  action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.wpAlbMasterTargetGroup.arn}"
  }
  condition {
    field  = "path-pattern"
    values = ["/wp-admin/*"]
  }
}
resource "aws_alb_listener_rule" "wp-admin-php" {
  listener_arn = "${aws_alb_listener.wpAlbListener.arn}"
  priority     = 2
  action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.wpAlbMasterTargetGroup.arn}"
  }
  condition {
    field  = "path-pattern"
    values = ["/wp-login.php"]
  }
}
resource "aws_alb_listener_rule" "contents-wp-admin" {
  listener_arn = "${aws_alb_listener.wpAlbListener.arn}"
  priority     = 3
  action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.wpAlbMasterTargetGroup.arn}"
  }
  condition {
    field  = "path-pattern"
    values = ["/contents/wp-admin/*"]
  }
}
resource "aws_alb_listener_rule" "contents-wp-admin-php" {
  listener_arn = "${aws_alb_listener.wpAlbListener.arn}"
  priority     = 4
  action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.wpAlbMasterTargetGroup.arn}"
  }
  condition {
    field  = "path-pattern"
    values = ["/contents/wp-login.php"]
  }
}
