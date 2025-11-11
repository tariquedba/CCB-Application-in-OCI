# Get availability domains
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

# Create 6 application servers
resource "oci_core_instance" "app_servers" {
  for_each = var.app_servers

  compartment_id      = var.compartment_ocid
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[each.value.ad_number - 1].name
  shape               = each.value.shape

  display_name = each.key

  shape_config {
    ocpus         = each.value.cpu
    memory_in_gbs = each.value.memory_gb
  }

  source_details {
    source_type = "image"
    source_id   = var.os_image_id
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.app_subnet.id
    display_name     = "${each.key}-vnic"
    assign_public_ip = true
    hostname_label   = each.key
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
  }

  # Boot volume
  launch_options {
    boot_volume_type = "PARAVIRTUALIZED"
  }

  # Extended metadata for application configuration
  extended_metadata = {
    "server_role"    = "application"
    "environment"    = "production"
    "backup_enabled" = "true"
  }

  timeouts {
    create = "60m"
  }
}

# Block volumes for additional storage (optional)
resource "oci_core_volume" "app_data_volumes" {
  for_each = var.app_servers

  compartment_id      = var.compartment_ocid
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[each.value.ad_number - 1].name
  display_name        = "${each.key}-data-volume"
  size_in_gbs        = each.value.disk_size
}
