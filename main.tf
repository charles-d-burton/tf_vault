// We launch Vault into an ASG so that it can properly bring them up for us.
resource "aws_autoscaling_group" "vault" {
  name                      = "tf-vault-${var.region}-asg"
  launch_configuration      = "${aws_launch_configuration.vault.name}"
  availability_zones        = ["${var.availability-zones}"]
  min_size                  = "${var.min_cluster_size}"
  max_size                  = "${var.max_cluster_size}"
  desired_capacity          = "${var.min_cluster_size}"
  health_check_grace_period = 15
  health_check_type         = "EC2"
  vpc_zone_identifier       = ["${var.subnets}"]
  target_group_arns         = ["${var.target_group_arn}"]

  tag {
    key                 = "Name"
    value               = "vault"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_notification" "vault_notifications" {
  group_names = [
    "${aws_autoscaling_group.vault.name}",
  ]

  notifications = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
  ]

  topic_arn = "${var.sns_alert_topic}"
}

resource "aws_launch_configuration" "vault" {
  image_id        = "${lookup(var.ami, var.region)}"
  instance_type   = "${var.instance_type}"
  key_name        = "${var.key_name}"
  security_groups = ["${aws_security_group.vault.id}"]
  user_data       = "${data.template_file.install.rendered}"

  lifecycle {
    create_before_destroy = true
  }
}

// Security group for Vault allows SSH and HTTP access (via "tcp" in
// case TLS is used)
resource "aws_security_group" "vault" {
  name        = "vault"
  description = "Vault servers"
  vpc_id      = "${var.vpc_id}"
}

resource "aws_security_group_rule" "vault-ssh" {
  security_group_id = "${aws_security_group.vault.id}"
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

// This rule allows Vault HTTP API access to individual nodes, since each will
// need to be addressed individually for unsealing.
resource "aws_security_group_rule" "vault_http_api" {
  security_group_id = "${aws_security_group.vault.id}"
  type              = "ingress"
  from_port         = 8200
  to_port           = 8200
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "vault_egress" {
  security_group_id = "${aws_security_group.vault.id}"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}
