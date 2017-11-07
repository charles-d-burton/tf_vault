data "template_file" "install" {
  template = "${file("${path.module}/configs/install.sh.tpl")}"

  vars {
    download_url = "${var.download_url}"
    consul       = "${var.consul_lb}"
  }
}
