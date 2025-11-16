locals {
  prefix = "cache-demo"
  freeform_tags = {
    Environment = "Dev"
    Project     = local.prefix
  }

  ocir_repository_prefix = "ocir.${var.region}.oci.oraclecloud.com/${var.namespace}/"

  vcns = [
    {
      vcn_name = "${local.prefix}-vcn"
      vcn_cidr = "10.100.0.0/16"
      subnets = [
        {
          display_name = "public-subnet-01"
          cidr_block   = "10.100.0.0/24"
          dns_label    = "public01"
          is_public    = true
        },
        {
          display_name = "public-subnet-02"
          cidr_block   = "10.100.1.0/24"
          dns_label    = "public02"
          is_public    = true
        },
        {
          display_name = "private-subnet-01"
          cidr_block   = "10.100.128.0/24"
          dns_label    = "private01"
          is_public    = false
        },
      ]
    },
  ]

  caches = [
    {
      display_name       = "${local.prefix}-cache"
      subnet_name        = "public-subnet-01"
      vcn_name           = "${local.prefix}-vcn"
      node_count         = 3
      node_memory_in_gbs = 4
      software_version   = "7"
      cache_users        = var.cache_users
    },
  ]

  databases = [
    {
      display_name = "${local.prefix}-database"
      db_version   = "POSTGRES_18"
      shape        = "VM.Standard2.1"
      username     = "adminuser"
      password     = var.db_password
      subnet_name  = "public-subnet-02"
      vcn_name     = "${local.prefix}-vcn"
    },
  ]
}
