locals {
  region_abbreviation_map = {
    "ap-tokyo-1" = "NRT"
    "ap-osaka-1" = "KIX"
  }
}

resource "oci_core_vcn" "main" {
  compartment_id = var.compartment_ocid
  display_name   = var.vcn_name
  cidr_block     = var.vcn_cidr
  is_ipv6enabled = false
  dns_label      = var.dns_label

  freeform_tags = merge({ Name = var.vcn_name }, var.freeform_tags)
}

resource "oci_core_internet_gateway" "igw" {
  compartment_id = var.compartment_ocid
  display_name   = var.igw_name
  vcn_id         = oci_core_vcn.main.id

  freeform_tags = merge({ Name = var.igw_name }, var.freeform_tags)
}

resource "oci_core_route_table" "public" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.main.id
  display_name   = "${var.route_name}-Public"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.igw.id
  }

  freeform_tags = merge({ Name = "${var.route_name}-Public" }, var.freeform_tags)
}

resource "oci_core_route_table" "private" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.main.id
  display_name   = "${var.route_name}-Private"

  freeform_tags = merge({ Name = "${var.route_name}-Private" }, var.freeform_tags)
}

resource "oci_core_security_list" "public" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.main.id
  display_name   = "${var.security_list_name}-Public"

  # Egress (All Outbound Traffic)
  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }

  # Ingress (Allow HTTPS on 443)
  ingress_security_rules {
    protocol  = "6"         # TCP
    source    = "0.0.0.0/0" # allow access from VCN CIDR
    stateless = false       # Required for connection tracking
    tcp_options {
      max = 443
      min = 443
    }
  }

  freeform_tags = merge({ Name = "${var.security_list_name}-Public" }, var.freeform_tags)
}

# same setting to public for simplicity
resource "oci_core_security_list" "private" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.main.id
  display_name   = "${var.security_list_name}-Private"

  # Egress (All Outbound Traffic)
  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }

  # Ingress (Allow HTTPS on 443)
  ingress_security_rules {
    protocol  = "6" # TCP
    source    = var.vcn_cidr
    stateless = false # Required for connection tracking
    tcp_options {
      max = 8080
      min = 8080
    }
  }

  freeform_tags = merge({ Name = "${var.security_list_name}-Private" }, var.freeform_tags)
}

data "oci_core_services" "test_services" {
  # This filter is the key to getting the correct service ID
  filter {
    name = "name"
    # The value below is the required template for Object Storage access
    values = ["All ${local.region_abbreviation_map[var.region]} Services In Oracle Services Network"]
    regex  = true
  }
}

resource "oci_core_service_gateway" "test_service_gateway" {
  compartment_id = var.compartment_ocid
  services {
    service_id = data.oci_core_services.test_services.services.0.id
  }
  vcn_id = oci_core_vcn.main.id

  display_name   = "${var.vcn_name}-Service-Gateway"
  freeform_tags  = merge({ Name = "${var.vcn_name}-Service-Gateway" }, var.freeform_tags)
  route_table_id = oci_core_route_table.private.id
}

resource "oci_core_subnet" "subnet" {
  for_each = { for sn in var.subnets : sn.display_name => sn }

  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.main.id
  cidr_block                 = each.value.cidr_block
  display_name               = each.key
  dns_label                  = each.value.dns_label
  prohibit_public_ip_on_vnic = false
  route_table_id             = each.value.is_public ? oci_core_route_table.public.id : oci_core_route_table.private.id
  security_list_ids          = [each.value.is_public ? oci_core_security_list.public.id : oci_core_security_list.private.id]
}
