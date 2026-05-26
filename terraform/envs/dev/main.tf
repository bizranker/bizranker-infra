terraform {
  required_version = ">= 1.5.0"

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 6.0"
    }
  }
}

provider "oci" {
  region = var.region
}

module "command_center_01" {
  source = "../../modules/oci_compute_instance"

  availability_domain = var.availability_domain
  compartment_id      = var.compartment_id
  display_name        = "bizranker-command-01"
  hostname_label      = "bizranker-command-01"

  shape            = var.command_center_shape
  ocpus            = var.command_center_ocpus
  memory_in_gbs    = var.command_center_memory
  subnet_id        = var.public_subnet_id
  assign_public_ip = true

  image_id       = var.ubuntu_image_id
  ssh_public_key = file(var.ssh_public_key_path)

  tags = {
    project = "bizranker"
    class   = "command_center_node"
    managed = "terraform"
  }
}
