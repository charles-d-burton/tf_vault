//-------------------------------------------------------------------
// Vault settings
//-------------------------------------------------------------------

variable "download_url" {
  default     = "https://releases.hashicorp.com/vault/0.8.3/vault_0.8.3_linux_amd64.zip"
  description = "URL to download Vault"
}

variable "consul_lb" {}

//-------------------------------------------------------------------
// AWS settings
//-------------------------------------------------------------------
variable "region" {}

variable "ami" {
  description = "AWS AMI Id, if you change, make sure it is compatible with instance type, not all AMIs allow all instance types "

  default = {
    us-west-1      = "ami-1c1d217c"
    us-west-2      = "ami-0a00ce72"
    us-east-1      = "ami-da05a4a0"
    us-east-2      = "ami-336b4456"
    sa-east-1      = "ami-466b132a"
    eu-west-1      = "ami-add175d4"
    eu-west-2      = "ami-ecbea388"
    eu-central-1   = "ami-97e953f8"
    ca-central-1   = "ami-8a71c9ee"
    ap-southeast-1 = "ami-67a6e604"
    ap-southeast-2 = "ami-41c12e23"
    ap-south-1     = "ami-bc0d40d3"
    ap-northeast-1 = "ami-15872773"
    ap-northeast-2 = "ami-7b1cb915"
  }
}

variable "availability-zones" {
  type        = "list"
  description = "Availability zones for launching the Vault instances"
}

variable "target_group_arn" {
  description = "The arn of the load balancer to attach to"
  type        = "string"
}

variable "alb-health-check" {
  default     = "HTTP:8200/v1/sys/health"
  description = "Health check for Vault servers"
}

variable "instance_type" {
  default     = "t2.micro"
  description = "Instance type for Vault instances"
}

variable "key_name" {
  default     = "default"
  description = "SSH key name for Vault instances"
}

variable "private_subnets" {
  description = "list of subnets to launch Vault within"
  type        = "list"
}

variable "vpc_id" {
  description = "VPC ID"
}

variable "notification_arn" {
  description = "SNS topic to send autoscaling alerts to"
}

variable "min_cluster_size" {
  description = "The number of Consul servers to launch."
  default     = 2
}

variable "max_cluster_size" {
  description = "The maximum number of nodes"
  default     = 5
}
