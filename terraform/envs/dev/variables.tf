variable "region" {
  type    = string
  default = "us-sanjose-1"
}

variable "availability_domain" { type = string }
variable "compartment_id" { type = string }
variable "public_subnet_id" { type = string }
variable "ubuntu_image_id" { type = string }

variable "ssh_public_key_path" {
  type    = string
  default = "~/.ssh/oracle-bizranker.pub"
}

variable "command_center_shape" {
  type    = string
  default = "VM.Standard.E5.Flex"
}

variable "command_center_ocpus" {
  type    = number
  default = 1
}

variable "command_center_memory" {
  type    = number
  default = 12
}

variable "private_subnet_id" {
  type = string
}
