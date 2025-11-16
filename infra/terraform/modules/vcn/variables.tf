# ----------------------------------------------------------------------------------------------------------------------
# OCI Tenancy and Compartment Variables
# ----------------------------------------------------------------------------------------------------------------------
variable "compartment_ocid" {
  type        = string
  description = "The OCID of the compartment where the resources will be created."
}

variable "region" {
  type        = string
  description = "The OCI region where resources will be created."
}

# ----------------------------------------------------------------------------------------------------------------------
# Networking Variables
# ----------------------------------------------------------------------------------------------------------------------
variable "vcn_name" {
  type        = string
  description = "The name for the Virtual Cloud Network (VCN)."
  default     = "vcn-main"
}

variable "vcn_cidr" {
  type        = string
  description = "The CIDR block for the VCN."
  default     = "10.0.0.0/16"
}

variable "dns_label" {
  type        = string
  description = "A DNS label for the VCN, used in the VCN's internal DNS hostname."
  default     = "vcnmain"
}

variable "igw_name" {
  type        = string
  description = "The name for the Internet Gateway."
  default     = "igw-main"
}

variable "route_name" {
  type        = string
  description = "The base name for the route tables."
  default     = "rt-main"
}

variable "security_list_name" {
  type        = string
  description = "The base name for the security lists."
  default     = "sl-main"
}

variable "subnets" {
  type = list(object({
    display_name = string
    cidr_block   = string
    dns_label    = string
    is_public    = bool
  }))
  description = "A list of subnets to create within the VCN. 'is_public' determines if it gets a public or private route table and security list."
  default = [
    {
      display_name = "public-subnet-1"
      cidr_block   = "10.0.1.0/24"
      dns_label    = "public1"
      is_public    = true
    },
    {
      display_name = "private-subnet-1"
      cidr_block   = "10.0.2.0/24"
      dns_label    = "private1"
      is_public    = false
    }
  ]
}

# ----------------------------------------------------------------------------------------------------------------------
# Tagging Variables
# ----------------------------------------------------------------------------------------------------------------------
variable "freeform_tags" {
  type        = map(string)
  description = "A map of freeform tags to apply to all resources."
  default     = {}
}
