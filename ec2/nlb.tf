module "nlb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "6.0.0"

  name_prefix = "nlb-"

  load_balancer_type = "network"
  vpc_id             = var.vpc_id
  subnets = [var.subnet_id]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "TCP"
      target_group_index = 0
    }
  ]

  target_groups = [
    {
      name_prefix          = "app1-"
      backend_protocol     = "TCP"
      backend_port         = 8081
      target_type          = "instance"
      deregistration_delay = 10
      health_check         = {
        enabled             = true
        interval            = 30
        path                = "/"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
      }
    }
  ]

  tags = {
    environment = "dev"
  }
}

output "nlb_target_group_arns" {
  description = "Alb Target Group Arns"
  value       = module.nlb.target_group_arns
}
