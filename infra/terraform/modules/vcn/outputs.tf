# ----------------------------------------------------------------------------------------------------------------------
# VCN Outputs
# ----------------------------------------------------------------------------------------------------------------------
output "id" {
  description = "The OCID of the created Virtual Cloud Network (VCN)."
  value       = oci_core_vcn.main.id
}

output "cidr_block" {
  description = "The CIDR block of the VCN."
  value       = oci_core_vcn.main.cidr_block
}

# ----------------------------------------------------------------------------------------------------------------------
# Gateway Outputs
# ----------------------------------------------------------------------------------------------------------------------
output "internet_gateway_id" {
  description = "The OCID of the Internet Gateway."
  value       = oci_core_internet_gateway.igw.id
}

# ----------------------------------------------------------------------------------------------------------------------
# Route Table Outputs
# ----------------------------------------------------------------------------------------------------------------------
output "public_route_table_id" {
  description = "The OCID of the public route table."
  value       = oci_core_route_table.public.id
}

output "private_route_table_id" {
  description = "The OCID of the private route table."
  value       = oci_core_route_table.private.id
}

# ----------------------------------------------------------------------------------------------------------------------
# Security List Outputs
# ----------------------------------------------------------------------------------------------------------------------
output "public_security_list_id" {
  description = "The OCID of the public security list."
  value       = oci_core_security_list.public.id
}

output "private_security_list_id" {
  description = "The OCID of the private security list."
  value       = oci_core_security_list.private.id
}

# ----------------------------------------------------------------------------------------------------------------------
# Subnet Outputs
# ----------------------------------------------------------------------------------------------------------------------
output "subnets" {
  description = "A map of the created subnets, keyed by their display names."
  value = { for k, v in oci_core_subnet.subnet : k => {
    id         = v.id
    cidr_block = v.cidr_block
    dns_label  = v.dns_label
  } }
}
