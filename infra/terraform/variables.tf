variable "tenancy_ocid" {
  description = "The OCID of your tenancy."
  type        = string
}

variable "user_ocid" {
  description = "The OCID of the user."
  type        = string
}

variable "private_key_path" {
  description = "The file path to the private key used for authentication."
  type        = string
}

variable "fingerprint" {
  description = "The fingerprint of the public key associated with the private key."
  type        = string
}

variable "compartment_ocid" {
  description = "The OCID of the compartment where resources will be created."
  type        = string
}

variable "region" {
  type        = string
  description = "The OCI region to deploy resources in."
  default     = "ap-tokyo-1"
}

variable "namespace" {
  type        = string
  description = "The OCI Object Storage namespace for the tenancy."
}

# ------------------------------------------------------------------------------
# secrets
# ------------------------------------------------------------------------------
variable "db_password" {
  type        = string
  description = "The password for the database admin user."
}

variable "cache_users" {
  type = list(object({
    name       = string
    password   = string
    acl_string = string
  }))
}
