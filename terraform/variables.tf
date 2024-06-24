## Service account variables

variable "credentials" {
  type = string
}

variable "client_email" {
  type = string
}

## Account variables

variable "project" {
  type = string
}

variable "region" {
  type = string
}

variable "zone" {
  type = string
}

variable "geth_image" {
  type    = string
  default = "docker.io/ethereum/client-go"
}

variable "geth_image_tag" {
  type    = string
  default = "v1.14.5"
}

variable "prysm_image" {
  type    = string
  default = "gcr.io/prysmaticlabs/prysm/beacon-chain"
}

variable "prysm_image_tag" {
  type    = string
  default = "v5.0.3"
}

variable "create_firewall_rule" {
  description = "Create tag-based firewall rule."
  type        = bool
  default     = false
}

variable "geth_machine_type" {
  type = string
}

variable "prysm_machine_type" {
  type = string
}

variable "geth_vm_tags" {
  description = "Additional network tags for the geth instances."
  type        = list(string)
  default     = ["geth-auth-rpc", "geth-http-rpc", "geth-ws-rpc", "geth-p2p", "geth-metrics"]
}

variable "prysm_vm_tags" {
  description = "Additional network tags for the geth instances."
  type        = list(string)
  default     = ["prysm-rpc", "prysm-p2p-udp", "prysm-p2p", "prysm-metrics"]
}

variable "jwt_hex_path" {
  type    = string
  default = "/etc/jwt.hex"
}

variable "jwt_hex_host_path" {
  type    = string
  default = "/mnt/stateful_partition/etc/jwt.hex"
}

variable "geth_datadir_disk_size" {
  type    = number
  default = 2500
}

variable "prysm_datadir_disk_size" {
  type    = number
  default = 250
}

# consumed by both geth and prysm on their respective containers
variable "datadir_path" {
  type    = string
  default = "/mnt/datadir"
}

# consumed by both geth and prysm on their respective VMs
variable "datadir_host_path" {
  type    = string
  default = "/mnt/disks/sdb"
}

variable "geth_rpc_source_range" {
  description = "Allowed IP source range for (unauthenticated) RPC related call."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "execution_endpoint" {
  type = string
}

variable "checkpoint_sync_url" {
  description = "https://eth-clients.github.io/checkpoint-sync-endpoints/#mainnet"
  type        = string
  default     = "https://beaconstate-mainnet.chainsafe.io"
}

variable "genesis_beacon_api_url" {
  description = "https://eth-clients.github.io/checkpoint-sync-endpoints/#mainnet"
  type        = string
  default     = "https://beaconstate-mainnet.chainsafe.io"
}

locals {
  environment  = terraform.workspace
  service_name = "eth-node"
  geth_image   = "${var.geth_image}:${var.geth_image_tag}"
  prysm_image  = "${var.prysm_image}:${var.prysm_image_tag}"
  volume_mounts = [
    {
      mountPath = var.jwt_hex_path
      name      = "jwt_hex"
      readOnly  = true
    },
    {
      mountPath = var.datadir_path
      name      = "datadir"
      readOnly  = false
    },
  ]
  volumes = [
    {
      name = "jwt_hex"
      hostPath = {
        path = var.jwt_hex_host_path
      }
    },
    {
      name = "datadir"
      hostPath = {
        path = var.datadir_host_path
      }
    },
  ]
}
