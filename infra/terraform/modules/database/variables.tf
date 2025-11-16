variable "compartment_id" {
  type        = string
  description = "The OCID of the compartment to create the PostgreSQL DB system in."
  nullable    = false
}

variable "db_version" {
  type        = string
  description = "The major version of PostgreSQL. (e.g., \"14\", \"15\")"
  default     = "14"
}

variable "display_name" {
  type        = string
  description = "A user-friendly display name for the DB system."
}

variable "shape" {
  type        = string
  description = "The shape of the DB system. (e.g., \"VM.Standard.E4.Flex\")"
}

variable "password_type" {
  type        = string
  description = "The password type. (e.g., \"PLAIN_TEXT\", \"VAULT_SECRET\")"
  default     = "PLAIN_TEXT"
}

variable "password" {
  type        = string
  description = "The password for the database administrator. Required if password_type is \"CLEAR\"."
  default     = null
  sensitive   = true
}

variable "username" {
  type        = string
  description = "The username for the database administrator."
  default     = "postgres"
}

variable "subnet_id" {
  type        = string
  description = "The OCID of the subnet for the DB system's primary endpoint."
}

variable "is_reader_endpoint_enabled" {
  type        = bool
  description = "Whether to enable a read-only endpoint for the DB system."
  default     = false
}

variable "nsg_ids" {
  type        = list(string)
  description = "A list of OCIDs for Network Security Groups to attach to the DB system."
  default     = []
}

variable "is_regionally_durable" {
  type        = bool
  description = "Specifies whether the DB system is regionally durable (high availability)."
  default     = false
}

variable "system_type" {
  type        = string
  description = "The system type."
  default     = "OCI_OPTIMIZED_STORAGE"
}

variable "availability_domain" {
  type        = string
  description = "The availability domain to place the DB system in. Required if is_regionally_durable is false."
  default     = null
}

variable "iops" {
  type        = number
  description = "The guaranteed IOPS for the storage. Only valid for 'VM' system_type."
  default     = null
}

variable "freeform_tags" {
  type        = map(string)
  description = "A map of freeform tags to apply to the resource."
  default     = {}
}
