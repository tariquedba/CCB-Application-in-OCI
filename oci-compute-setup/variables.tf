variable "tenancy_ocid" {
  description = "OCID tenancy ID"
  type        = string
}

variable "user_ocid" {
  description = "OCID of tenancy user"
  type        = string
}

variable "fingerprint" {
  description = "Fingerprint of your API key"
  type        = string
}

variable "private_key_path" {
  description = "API KEY PATH"
  type        = string
}

variable "region" {
  description = "OCI region (e.g., me-dubai-1)"
  type        = string
  default     = "me-dubai-1"
}

variable "compartment_ocid" {
  description = "compartment name"
  type        = string
}

variable "vcn_cidr_block" {
  description = "CIDR block for VCN"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr_block" {
  description = "CIDR block for subnet"
  type        = string
  default     = "10.0.1.0/24"
}

# Application Server Configuration
variable "app_servers" {
  description = "Configuration for application servers"
  type = map(object({
    ad_number  = number
    shape      = string
    cpu        = number
    memory_gb  = number
    disk_size  = number
  }))
  default = {
    app-server-1 = { ad_number = 1, shape = "VM.Standard.E4.Flex", cpu = 2, memory_gb = 16, disk_size = 100 }
    app-server-2 = { ad_number = 1, shape = "VM.Standard.E4.Flex", cpu = 2, memory_gb = 16, disk_size = 100 }
    app-server-3 = { ad_number = 2, shape = "VM.Standard.E4.Flex", cpu = 2, memory_gb = 16, disk_size = 100 }
    app-server-4 = { ad_number = 2, shape = "VM.Standard.E4.Flex", cpu = 2, memory_gb = 16, disk_size = 100 }
    app-server-5 = { ad_number = 3, shape = "VM.Standard.E4.Flex", cpu = 4, memory_gb = 32, disk_size = 150 }
    app-server-6 = { ad_number = 3, shape = "VM.Standard.E4.Flex", cpu = 4, memory_gb = 32, disk_size = 150 }
  }
}

variable "ssh_public_key" {
  description = "SSH public key for instance access"
  type        = string
}

variable "os_image_id" {
  description = "OCID of the OS image"
  type        = string
  default     = "ocid1.image.oc1..aaaaaaaazn2irxdz7nvg6j7pqzr6qm7kfhjjlbyjkw2y75qgqg3fnqrp6rga" # Oracle Linux 8
}
