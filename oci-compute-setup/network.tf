# VCN
resource "oci_core_vcn" "app_vcn" {
  compartment_id = var.compartment_ocid
  cidr_block     = var.vcn_cidr_block
  display_name   = "ccb-app-vcn"
  dns_label      = "ccbapp"
}

# Internet Gateway
resource "oci_core_internet_gateway" "igw" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.app_vcn.id
  display_name   = "ccb-igw"
}

# Route Table
resource "oci_core_route_table" "public_rt" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.app_vcn.id
  display_name   = "public-route-table"

  route_rules {
    destination       = "*.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.igw.id
  }
}

# Security List
resource "oci_core_security_list" "app_security_list" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.app_vcn.id
  display_name   = "app-security-list"

  # SSH access
  ingress_security_rules {
    protocol  = "6"
    source    = "*.0.0.0/0"
    stateless = false

    tcp_options {
      min = 22
      max = 22
    }
  }

  # HTTP access
  ingress_security_rules {
    protocol  = "6"
    source    = "*.0.0.0/0"
    stateless = false

    tcp_options {
      min = 80
      max = 80
    }
  }

  # HTTPS access
  ingress_security_rules {
    protocol  = "6"
    source    = "*.0.0.0/0"
    stateless = false

    tcp_options {
      min = 443
      max = 443
    }
  }

  # Application ports (customize as needed)
  ingress_security_rules {
    protocol  = "6"
    source    = "*.0.0.0/16"
    stateless = false

    tcp_options {
      min = 8000
      max = 9000
    }
  }

  # Outbound traffic
  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
    stateless   = false
  }
}

# Subnet
resource "oci_core_subnet" "app_subnet" {
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_vcn.app_vcn.id
  cidr_block        = var.subnet_cidr_block
  display_name      = "ccb-app-subnet"
  dns_label         = "appsubnet"
  route_table_id    = oci_core_route_table.public_rt.id
  security_list_ids = [oci_core_security_list.app_security_list.id]
  prohibit_public_ip_on_vnic = false
}
