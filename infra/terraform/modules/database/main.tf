resource "oci_psql_db_system" "this" {
  compartment_id = var.compartment_id
  db_version     = var.db_version
  display_name   = var.display_name
  shape          = var.shape

  credentials {
    password_details {
      password_type = var.password_type
      password      = var.password
    }
    username = var.username
  }

  network_details {
    subnet_id                  = var.subnet_id
    is_reader_endpoint_enabled = var.is_reader_endpoint_enabled
    nsg_ids                    = var.nsg_ids
  }

  storage_details {
    is_regionally_durable = var.is_regionally_durable
    system_type           = var.system_type
    availability_domain   = var.availability_domain
    iops                  = var.iops
  }
}
