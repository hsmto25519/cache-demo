# ------------------------------------------------------------------------------
# General Variables
# ------------------------------------------------------------------------------

variable "compartment_id" {
  type        = string
  description = "The OCID of the compartment where the Redis cluster and users will be created."
}

variable "display_name" {
  type        = string
  description = "A user-friendly name for the Redis cluster. This will also be used as a prefix for user names in tags."
}

variable "freeform_tags" {
  type        = map(string)
  description = "A map of freeform tags to apply to all resources."
  default     = {}
}

# ------------------------------------------------------------------------------
# Network Variables
# ------------------------------------------------------------------------------

variable "subnet_id" {
  type        = string
  description = "The OCID of the subnet to host the cluster's private endpoint."
}

variable "nsg_ids" {
  type        = list(string)
  description = "A list of Network Security Group OCIDs to associate with the cluster."
  default     = []
}

# ------------------------------------------------------------------------------
# Cluster Configuration Variables
# ------------------------------------------------------------------------------

variable "cluster_mode" {
  type        = string
  description = "The mode of the cluster, either 'SHARDED' or 'NONSHARDED'."
  default     = "SHARDED"

  validation {
    condition     = contains(["SHARDED", "NONSHARDED"], var.cluster_mode)
    error_message = "Valid values for cluster_mode are 'SHARDED' or 'NONSHARDED'."
  }
}

variable "node_count" {
  type        = number
  description = "The number of nodes in the cluster (inclusive of shards and replicas)."
  # Example: For a 3-shard cluster with 1 replica per shard, node_count would be 6 (3 * (1+1)).
}

variable "node_memory_in_gbs" {
  type        = number
  description = "The amount of memory (in GBs) for each node."
}

variable "shard_count" {
  type        = number
  description = "The number of shards in the cluster. Required if cluster_mode is 'SHARDED'."
  default     = null
}

variable "software_version" {
  type        = string
  description = "The software version of the Redis cluster (e.g., '7.0')."
  default     = "7.0"
}

variable "security_attributes" {
  type        = any
  description = "Optional security attributes for the cluster (e.g., for TLS settings). Refer to OCI documentation for structure."
  default     = null
}

variable "cache_users" {
  type = list(object({
    name        = string
    description = optional(string, "no description provided")
    acl_string  = string
    password    = string
  }))
  description = "A list of user objects to create. 'password' must be a list of pre-hashed passwords."
  default     = []
}

variable "authentication_type" {
  type        = string
  description = "The authentication mode for users."
  default     = "PASSWORD"
}
