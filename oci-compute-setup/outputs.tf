output "instance_public_ips" {
  description = "Public IP addresses of the application servers"
  value = {
    for key, instance in oci_core_instance.app_servers :
    key => instance.public_ip
  }
}

output "instance_private_ips" {
  description = "Private IP addresses of the application servers"
  value = {
    for key, instance in oci_core_instance.app_servers :
    key => instance.private_ip
  }
}

output "vcn_id" {
  description = "OCID of the VCN"
  value       = oci_core_vcn.app_vcn.id
}

output "subnet_id" {
  description = "OCID of the subnet"
  value       = oci_core_subnet.app_subnet.id
}
