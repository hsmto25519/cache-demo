output "db_system_id" {
  description = "The OCID of the PostgreSQL DB system."
  value       = oci_psql_db_system.this.id
}

output "primary_private_ip" {
  description = "The primary private IP address of the DB system endpoint."
  value       = oci_psql_db_system.this.network_details[0].primary_db_endpoint_private_ip
}

output "db_instance_endpoints" {
  description = "The list of DB instance endpoints."
  value       = oci_psql_db_system.this.db_instance_endpoints
}