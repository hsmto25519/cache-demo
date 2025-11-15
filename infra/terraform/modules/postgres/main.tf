resource "oci_psql_db_system" "this" {
  compartment_id = var.compartment_id
  display_name   = var.display_name
  shape          = var.shape
  db_version     = var.db_version

  instance_count              = var.instance_count
  instance_ocpu_count         = var.instance_ocpu_count
  instance_memory_size_in_gbs = var.instance_memory_size_in_gbs

  credentials {
    password_details {
      password_type = "PlainTextPasswordDetails"
      password      = var.password
    }
    username = var.username
  }

  network_details {
    subnet_id = var.subnet_id
    is_reader_endpoint_enabled = var.is_reader_endpoint_enabled
    nsg_ids = var.nsg_ids
  }

  storage_details {
    availability_domain = var.availability_domain
    system_type           = "PIOPS"
    is_regionally_durable = var.is_regionally_durable
  }

  freeform_tags = merge({ Name = var.display_name }, var.freeform_tags)
}