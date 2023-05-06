resource "aws_launch_template" "my_launch_template" {
  name_prefix = "test-"
  description = "My Launch template"
  image_id = "ami-03f54df9441e9b380"
  instance_type = "t2.medium"

  vpc_security_group_ids = [ module.ec2_sg.security_group_id ]
  key_name = "bhhan-instance-key"
  user_data = base64encode(templatefile("${path.module}/app1-install.tpl", {
    efs_mount_point = "nexus"
    file_system_id  = "fs-02702d74352d7e9fb"
  }))
  update_default_version = true

  monitoring {
    enabled = true
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "test"
    }
  }
}
