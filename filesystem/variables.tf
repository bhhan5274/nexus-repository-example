variable "public_instance_sg_ports" {

  description = "Define the ports and protocols for instance the security group"
  type        = list(any)
  default = [
    {
      "port" : 22,
      "protocol" : "tcp"
    },
  ]
}

variable "efs_sg_ports" {

  description = "Define the ports and protocols for efs the security group"
  type        = list(any)
  default = [
    {
      "port" : 2049,
      "protocol" : "tcp"
    },
  ]
}

variable "efs_mount_point" {
  description = "Determine the mount point"
  type        = string
  default     = "content/test/"
}
