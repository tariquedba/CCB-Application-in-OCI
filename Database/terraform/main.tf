# CCB Database Migration to OCI DBaaS
# Oracle Database Service with Data Guard

terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 4.0.0"
    }
  }
}

provider "oci" {
  tenancy_ocid = var.tenancy_ocid
  region       = "me-dubai-1"
}

# Compartment for Database Resources
resource "oci_identity_compartment" "ccb_database" {
  compartment_id = var.tenancy_ocid
  name           = "CCB-Database"
  description    = "Compartment for CCB database resources"
  enable_delete  = true
}

# Database Subnet (Private)
resource "oci_core_subnet" "db_subnet" {
  compartment_id = oci_identity_compartment.ccb_database.id
  vcn_id         = var.vcn_id
  cidr_block     = "10.0.2.0/24"
  display_name   = "CCB-DB-Subnet"
  dns_label      = "ccbdbsubnet"

  prohibit_public_ip_on_vnic = true
  security_list_ids          = [oci_core_security_list.db_security_list.id]
}

# Database Security List (Restricted Access)
resource "oci_core_security_list" "db_security_list" {
  compartment_id = oci_identity_compartment.ccb_database.id
  vcn_id         = var.vcn_id
  display_name   = "CCB-DB-SecurityList"

  # Only allow from application servers
  ingress_security_rules {
    protocol  = "6"  # TCP
    source    = "10.0.1.0/24"  # App server subnet
    stateless = false

    tcp_options {
      min = 1521  # Oracle Database
      max = 1521
    }
  }

  # Allow SSH from management network only
  ingress_security_rules {
    protocol  = "6"
    source    = var.management_cidr
    stateless = false

    tcp_options {
      min = 22
      max = 22
    }
  }

  # Data Guard replication
  ingress_security_rules {
    protocol  = "6"
    source    = "10.0.3.0/24"  # DR subnet
    stateless = false

    tcp_options {
      min = 1521
      max = 1521
    }
  }

  # Allow all outbound
  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
    stateless   = false
  }
}

# Primary Database System
resource "oci_database_db_system" "ccb_primary_db" {
  compartment_id = oci_identity_compartment.ccb_database.id
  availability_domain = data.oci_identity_availability_domains.dubai_ads.availability_domains[0].name
  
  db_home {
    database {
      admin_password = var.db_admin_password
      db_name        = "CCBPRD"
      character_set  = "AL32UTF8"
      ncharacter_set = "AL16UTF16"
      db_workload    = "OLTP"
      
      db_backup_config {
        auto_backup_enabled = true
        auto_backup_window  = "SLOT_TWO"
        recovery_window_in_days = 35
      }
    }
    db_version = "19.0.0.0"
  }

  db_system_options {
    storage_management = "ASM"
  }

  # Exadata Shape for Performance
  shape               = "ExtermrePeformance.Quarter2.32"
  display_name        = "CCB-Primary-DB"
  hostname            = "****"
  domain              = "ccb.internal"
  ssh_public_keys     = [file(var.ssh_public_key_path)]
  subnet_id           = oci_core_subnet.db_subnet.id
  backup_subnet_id    = oci_core_subnet.db_subnet.id
  
  license_model       = "LICENSE_INCLUDED"
  node_count          = 2  # RAC nodes
  
  # Storage Configuration
  data_storage_size_in_gb = 4096
  database_edition        = "ENTERPRISE_EDITION_EXTREME_PERFORMANCE"
  
  # Maintenance
  maintenance_window_details {
    preference = "CUSTOM_PREFERENCE"
    hours_of_day = [4]
    months = [
      {
        name = "JANUARY"
      },
      {
        name = "APRIL"
      },
      {
        name = "JULY"
      },
      {
        name = "OCTOBER"
      }
    ]
    weeks_of_month = [1]
    days_of_week {
      name = "MONDAY"
    }
  }
}

# Data Guard Association
resource "oci_database_data_guard_association" "ccb_data_guard" {
  depends_on = [oci_database_db_system.ccb_primary_db]

  creation_type       = "NewDbSystem"
  database_admin_password = var.db_admin_password
  database_id         = oci_database_db_system.ccb_primary_db.db_home[0].database[0].id
  protection_mode     = "MAXIMUM_PERFORMANCE"
  transport_type      = "ASYNC"
  
  # Create standby in different AD for HA
  availability_domain = data.oci_identity_availability_domains.dubai_ads.availability_domains[1].name
  display_name        = "CCB-Standby-DB"
  hostname            = "ccbdbstdby"
  shape               = "Exadata.Quarter2.32"
  subnet_id           = oci_core_subnet.db_subnet.id
  
  # Same storage configuration
  data_storage_size_in_gb = 4096
}

# Database Backup Policy
resource "oci_database_backup_destination" "ccb_backup" {
  compartment_id = oci_identity_compartment.ccb_database.id
  display_name   = "CCB-Backup-Destination"
  type           = "NFS"
  
  connection_string = var.backup_destination
  vpc_users        = ["backupuser"]
}

# Database Service Monitoring
resource "oci_monitoring_alarm" "db_performance_alarm" {
  compartment_id = oci_identity_compartment.ccb_database.id
  destinations   = [var.notification_topic_id]
  display_name   = "CCB-DB-Performance-Alarm"
  
  metric_compartment_id = oci_identity_compartment.ccb_database.id
  namespace      = "oci_database"
  metric_name    = "CpuUtilization"
  query          = "CpuUtilization[1m].max() > 80"
  
  severity       = "WARNING"
  message_format = "JSON"
}

# Output Database Connection Information
output "primary_db_connection" {
  description = "Primary database connection details"
  value       = {
    hostname = oci_database_db_system.ccb_primary_db.hostname
    service_name = "CCBPRD.${oci_database_db_system.ccb_primary_db.domain}"
    port     = 1521
  }
  sensitive = true
}

output "data_guard_status" {
  description = "Data Guard configuration status"
  value       = oci_database_data_guard_association.ccb_data_guard.state
}

# Data source for availability domains
data "oci_identity_availability_domains" "dubai_ads" {
  compartment_id = var.tenancy_ocid
}
