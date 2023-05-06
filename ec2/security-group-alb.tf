module "loadbalancer_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.0.0"

  name = "application-loadbalancer-sg"
  description = "Security Group with HTTP open for entire Internet (IPv4 CIDR), egress ports are all world open"
  vpc_id = var.vpc_id
  ingress_rules = ["http-80-tcp", "https-443-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules = ["all-all"]
  tags = {
    environment = "dev"
  }
}
