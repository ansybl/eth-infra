variable "prefix" {
  description = "Prefix to prepend to resource names."
  type        = string
}

variable "environment" {
  type = string
}

variable "network_name" {
  type = string
}

variable "vm_tags" {
  description = "Additional network tags for the instances."
  type        = list(string)
  default     = []
}

variable "enable_gcp_logging" {
  description = "Enable the Google logging agent."
  type        = bool
  default     = true
}

variable "enable_gcp_monitoring" {
  description = "Enable the Google monitoring agent."
  type        = bool
  default     = true
}

variable "create_firewall_rule" {
  description = "Create tag-based firewall rule."
  type        = bool
  default     = false
}

variable "geth_auth_rpc_port" {
  description = "Port for authenticated APIs."
  type        = number
  default     = 8551
}

variable "geth_http_rpc_port" {
  description = "Port for HTTP RPC."
  type        = number
  default     = 8545
}

variable "geth_ws_rpc_port" {
  description = "Port for WS RPC."
  type        = number
  default     = 8546
}

variable "geth_rpc_source_range" {
  description = "Allowed IP source range for (unauthenticated) RPC related call."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "geth_p2p_port" {
  description = "Port for P2P."
  type        = number
  default     = 30303
}

variable "geth_metrics_port" {
  description = "Port for metrics."
  type        = number
  default     = 6060
}

variable "prysm_rpc_port" {
  description = "gRPC port exposed by a beacon node."
  type        = number
  default     = 4000
}

variable "prysm_p2p_udp_port" {
  description = "The port used by discv5."
  type        = number
  default     = 12000
}

variable "prysm_p2p_port" {
  description = "The port used by libp2p."
  type        = number
  default     = 13000
}

variable "prysm_metrics_port" {
  description = "Port for metrics."
  type        = number
  default     = 8080
}

variable "prysm_json_rpc_port" {
  description = "RPC port exposed by a beacon node."
  type        = number
  default     = 3500
}

variable "datadir_disk_size" {
  description = "Persistent disk size (GB) used for the datadir"
  type        = number
  default     = 100
}

variable "create_static_ip" {
  description = "Create a static IP"
  type        = bool
  default     = false
}

variable "instance_name" {
  description = "The desired name to assign to the deployed instance"
}

variable "instance_name_suffix" {
  description = "Legacy backward compatibility so that existing resources don't get replaced."
  type        = string
  default     = ""
}

variable "image" {
  description = "The Docker image to deploy to GCE instances"
}

variable "env_variables" {
  type    = map(string)
  default = null
}

variable "privileged_mode" {
  type    = bool
  default = false
}

# gcloud compute machine-types list | grep micro | grep us-central1-a
# e2-micro / 2 / 1.00
# f1-micro / 1 / 0.60
# gcloud compute machine-types list | grep small | grep us-central1-a
# e2-small / 2 / 2.00
# g1-small / 1 / 1.70
variable "machine_type" {
  type    = string
  default = "f1-micro"
}

variable "activate_tty" {
  type    = bool
  default = false
}

variable "custom_command" {
  type    = list(string)
  default = null
}

variable "custom_args" {
  type    = list(string)
  default = null
}

variable "additional_metadata" {
  type        = map(string)
  description = "Additional metadata to attach to the instance"
  default     = null
}

variable "client_email" {
  description = "Service account email address"
  type        = string
  default     = null
}

variable "metadata_startup_script" {
  type    = string
  default = ""
}

variable "volume_mounts" {
  type = list(object({
    mountPath = string
    name      = string
    readOnly  = bool
  }))
  default = []
}

variable "volumes" {
  type = list(object({
    name = string,
    hostPath = object({
      path = string,
    })
  }))
  default = []
}
