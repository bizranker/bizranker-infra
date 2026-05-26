variable "availability_domain" { type = string }
variable "compartment_id" { type = string }
variable "display_name" { type = string }
variable "shape" { type = string }
variable "subnet_id" { type = string }
variable "assign_public_ip" { type = bool }
variable "image_id" { type = string }
variable "ssh_public_key" { type = string }

variable "ocpus" {
  type    = number
  default = 1
}

variable "memory_in_gbs" {
  type    = number
  default = 12
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "hostname_label" {
  type    = string
  default = null
}
