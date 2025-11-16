module "vcns" {
  source = "./modules/vcn"

  for_each = { for vcn in local.vcns : vcn.vcn_name => vcn }

  region           = var.region
  vcn_name         = each.key
  vcn_cidr         = each.value.vcn_cidr
  subnets          = each.value.subnets
  compartment_ocid = var.compartment_ocid
  freeform_tags    = local.freeform_tags
}

module "caches" {
  source = "./modules/cache"

  for_each = { for cache in local.caches : cache.display_name => cache }

  compartment_id     = var.compartment_ocid
  node_count         = each.value.node_count
  display_name       = each.key
  node_memory_in_gbs = each.value.node_memory_in_gbs
  subnet_id          = module.vcns[each.value.vcn_name].subnets[each.value.subnet_name].id
  software_version   = each.value.software_version
  cache_users        = each.value.cache_users

  freeform_tags = local.freeform_tags
}

module "databases" {
  source = "./modules/database"

  for_each = { for db in local.databases : db.display_name => db }

  compartment_id = var.compartment_ocid
  display_name   = each.key
  db_version     = each.value.db_version
  shape          = each.value.shape
  username       = each.value.username
  password       = each.value.password
  #   password_type              = each.value.password_type
  subnet_id = module.vcns[each.value.vcn_name].subnets[each.value.subnet_name].id
  #   is_reader_endpoint_enabled = each.value.is_reader_endpoint_enabled
  #   is_regionally_durable      = each.value.is_regionally_durable
  #   system_type                = each.value.system_type
  #   availability_domain        = each.value.availability_domain
  #   iops                       = each.value.iops
  freeform_tags = local.freeform_tags
}
