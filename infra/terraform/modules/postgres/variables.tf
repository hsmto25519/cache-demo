variable "compartment_id" {
  description = "The OCID of the compartment to create the PostgreSQL DB system in."
  type        = string
}

variable "display_name" {
  description = "A user-friendly display name for the DB system."
  type        = string
}

variable "shape" {
  description = "The shape of the DB system. Example: 'VM.Standard.E4.Flex'."
  type        = string
}

variable "subnet_id" {
  description = "The OCID of the subnet for the DB system's primary endpoint."
  type        = string
}

variable "password" {
  description = "The administrator password for the database. Must meet OCI complexity requirements."
  type        = string
  sensitive   = true
}

variable "instance_ocpu_count" {
  description = "The number of OCPUs to allocate to each DB instance."
  type        = number
}

variable "instance_memory_size_in_gbs" {
  description = "The memory size in GBs to allocate to each DB instance."
  type        = number
}

variable "username" {
  description = "The administrator username for the database."
  type        = string
  default     = "postgres"
}

variable "db_version" {
  description = "The major and minor versions of the PostgreSQL database. Example: 'POSTGRESQL_14'."
  type        = string
  default     = "POSTGRESQL_14"
}

variable "instance_count" {
  description = "The number of DB instances."
  type        = number
  default     = 1
}

variable "is_reader_endpoint_enabled" {
  description = "Specifies whether to enable a read-only endpoint for the DB system."
  type        = bool
  default     = false
}

variable "nsg_ids" {
  description = "A list of OCIDs for Network Security Groups to associate with the DB system."
  type        = list(string)
  default     = []
}

variable "is_regionally_durable" {
  description = "Specifies whether the storage is regionally durable (true) or AD-local (false)."
  type        = bool
  default     = true
}

variable "availability_domain" {
  description = "The availability domain (AD) for the storage. Required if 'is_regionally_durable' is false. Must be null if 'is_regionally_durable' is true."
  type        = string
  default     = null
}

variable "freeform_tags" {
  description = "Free-form tags to apply to the resource."
  type        = map(string)
  default     = {}
}