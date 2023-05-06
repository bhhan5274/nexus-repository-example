# Autoscaling Group Resource
resource "aws_autoscaling_group" "my_asg" {
  name_prefix = "test-"
  max_size = 1
  min_size = 1
  desired_capacity = 1
  vpc_zone_identifier = [var.subnet_id]
  target_group_arns = module.nlb.target_group_arns
  health_check_type = "EC2"

  launch_template {
    id = aws_launch_template.my_launch_template.id
    version = aws_launch_template.my_launch_template.latest_version
  }
  # Instance Refresh
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
    triggers = [ "desired_capacity" ]
  }
  tag {
    key                 = "Owners"
    value               = "Web-Team"
    propagate_at_launch = true
  }
}
