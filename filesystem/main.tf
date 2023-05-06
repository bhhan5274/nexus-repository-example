################## Create VPC  ##################
module "vpc" {

  source  = "shamimice03/vpc/aws"
  version = "1.0.1"

  vpc_name = "efs_vpc"
  cidr     = "192.168.0.0/16"

  azs                = ["ap-northeast-2a", "ap-northeast-2c"]
  public_subnet_cidr = ["192.168.0.0/20", "192.168.16.0/20"]

  enable_dns_hostnames      = true
  enable_dns_support        = true
  enable_single_nat_gateway = false

  tags = {
    "Team" = "platform-team"
    "Env"  = "efs-test"
  }

}

################## Outputs  ##################
output "public_subnet" {
  value = module.vpc.public_subnet_id[0]
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "file_system_id" {
  value = aws_efs_file_system.file_system_1.id
}

################## Create Security Group for Private Instances  ##################
resource "aws_security_group" "efs_sg" {
  name        = "allow_from_public_instances"
  description = "Allow traffic from public instance sg only"
  vpc_id      = module.vpc.vpc_id

  dynamic "ingress" {

    for_each = var.efs_sg_ports
    content {
      from_port       = ingress.value["port"]
      to_port         = ingress.value["port"]
      protocol        = ingress.value["protocol"]
      cidr_blocks = ["192.168.0.0/16"]
    }
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "efs_sg"
  }
}

################## Create EFS File system ################
resource "aws_efs_file_system" "file_system_1" {
  creation_token   = "efs-test"
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"
  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }
  tags = {
    Name = "efs-test"
  }
}

################## Create EFS mount targets ################
resource "aws_efs_mount_target" "mount_targets" {
  file_system_id  = aws_efs_file_system.file_system_1.id
  subnet_id       = module.vpc.public_subnet_id[0]
  security_groups = [aws_security_group.efs_sg.id]
}

################## Generating Script for Mounting EFS ##################
resource "null_resource" "generate_efs_mount_script" {

  provisioner "local-exec" {
    command = templatefile("efs_mount.tpl", {
      efs_mount_point = var.efs_mount_point
      file_system_id  = aws_efs_file_system.file_system_1.id
    })
    interpreter = [
      "bash",
      "-c"
    ]
  }
}
