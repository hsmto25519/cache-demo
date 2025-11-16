output "db_system_id" {
  description = "The OCID of the PostgreSQL DB system."
  value       = oci_psql_db_system.this.id
}

output "primary_endpoint_private_ip" {
  description = "The private IP address of the primary database endpoint."
  value       = oci_psql_db_system.this.network_details[0].primary_db_endpoint_private_ip
}
