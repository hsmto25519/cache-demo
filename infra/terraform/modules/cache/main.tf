resource "oci_redis_redis_cluster" "this" {
  compartment_id     = var.compartment_id
  display_name       = var.display_name
  node_count         = var.node_count
  node_memory_in_gbs = var.node_memory_in_gbs
  software_version   = var.software_version
  subnet_id          = var.subnet_id

  cluster_mode        = var.cluster_mode
  nsg_ids             = var.nsg_ids
  security_attributes = var.security_attributes
  shard_count         = var.cluster_mode == "SHARDED" ? var.shard_count : null
  # oci_cache_config_set_id = oci_redis_oci_cache_config_set.this.id

  freeform_tags = merge({ Name = var.display_name }, var.freeform_tags)
}

resource "oci_redis_oci_cache_user" "this" {
  for_each = { for user in var.cache_users : user.name => user }

  compartment_id = var.compartment_id
  name           = each.key
  description    = each.value.description

  acl_string = each.value.acl_string
  authentication_mode {
    authentication_type = var.authentication_type
    hashed_passwords    = [base64sha256(each.value.password)]
  }

  freeform_tags = merge({ Name = "${var.display_name}-${each.key}" }, var.freeform_tags)
}
