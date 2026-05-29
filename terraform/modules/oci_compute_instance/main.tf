resource "oci_core_instance" "this" {
  availability_domain = var.availability_domain
  compartment_id      = var.compartment_id
  display_name        = var.display_name
  shape               = var.shape

dynamic "shape_config" {
  for_each = can(regex("Flex$", var.shape)) ? [1] : []

  content {
    ocpus         = var.ocpus
    memory_in_gbs = var.memory_in_gbs
  }
}

  create_vnic_details {
    subnet_id                 = var.subnet_id
    assign_public_ip          = var.assign_public_ip
    assign_private_dns_record = true
    hostname_label            = var.hostname_label
    display_name              = "${var.display_name}-vnic"
  }

  source_details {
    source_type             = "image"
    source_id               = var.image_id
    boot_volume_size_in_gbs = 47
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
  }

  freeform_tags = var.tags
}
