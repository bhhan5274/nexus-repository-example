# AWS EC2 Security Group Terraform Module
# Security Group for Private EC2 Instances
module "ec2_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.0.0"
  name = "ec2-sg"
  description = "Security Group with HTTP & SSH port open for entire VPC Block (IPv4 CIDR), egress ports are all world open"
  vpc_id = var.vpc_id
  ingress_with_cidr_blocks = [
    {
      from_port   = "22"
      to_port     = "22"
      protocol    = "tcp"
      description = "ssh rule"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = "8081"
      to_port     = "8081"
      protocol    = "tcp"
      description = "container rule"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
  egress_rules = ["all-all"]
  tags = {
    environment = "dev"
  }
}
