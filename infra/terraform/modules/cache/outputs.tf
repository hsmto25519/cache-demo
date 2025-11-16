output "cluster_id" {
  description = "The OCID of the created cache cluster."
  value       = oci_redis_redis_cluster.this.id
}

output "software_version" {
  description = "The software version of the cluster."
  value       = oci_redis_redis_cluster.this.software_version
}

output "node_count" {
  description = "The number of nodes in the cluster."
  value       = oci_redis_redis_cluster.this.node_count
}
