terraform {
  backend "gcs" {
    bucket      = "eth-node-infra-bucket-tfstate"
    prefix      = "terraform/state"
    credentials = "../terraform-service-key.json"
  }
}

provider "google" {
  project     = var.project
  credentials = file(var.credentials)
  region      = var.region
  zone        = var.zone
}

provider "google-beta" {
  project     = var.project
  credentials = file(var.credentials)
  region      = var.region
  zone        = var.zone
}

resource "google_storage_bucket" "default" {
  name          = "${local.service_name}-infra-bucket-tfstate"
  force_destroy = false
  location      = "US"
  storage_class = "STANDARD"
  versioning {
    enabled = true
  }
}

data "local_file" "format_script" {
  filename = "${path.module}/format.sh"
}

data "template_file" "setup_jwt_auth_script" {
  template = file("${path.module}/setup_jwt_auth.sh.tpl")
  vars = {
    jwt_hex_path = var.jwt_hex_host_path
    jwt_hex      = data.google_secret_manager_secret_version.jwt_hex.secret_data
  }
}

module "gce_geth_worker_container" {
  source = "./gce-with-container"
  image  = local.geth_image
  custom_args = [
    "--datadir",
    var.datadir_path,
    "--http",
    "--ws",
    "--http.addr",
    "0.0.0.0",
    "--http.vhosts",
    "*",
    "--ws.addr",
    "0.0.0.0",
    "--authrpc.addr",
    "0.0.0.0",
    "--authrpc.vhosts",
    "*",
    "--authrpc.jwtsecret",
    var.jwt_hex_path,
    "--metrics",
    "--pprof",
    "--pprof.addr",
    "0.0.0.0",
  ]
  privileged_mode       = true
  activate_tty          = true
  machine_type          = var.geth_machine_type
  prefix                = local.service_name
  environment           = local.environment
  env_variables         = {}
  instance_name         = "geth"
  instance_name_suffix  = "c84e80e6"
  network_name          = "default"
  create_static_ip      = true
  create_firewall_rule  = var.create_firewall_rule
  geth_rpc_source_range = var.geth_rpc_source_range
  vm_tags               = var.geth_vm_tags
  # This has the permission to download images from Container Registry
  client_email      = var.client_email
  datadir_disk_size = var.geth_datadir_disk_size
  volume_mounts     = local.volume_mounts
  volumes           = local.volumes
  metadata_startup_script = join("\n", [
    data.template_file.setup_jwt_auth_script.rendered,
    data.local_file.format_script.content,
  ])
}

module "gce_prysm_worker_container" {
  source = "./gce-with-container"
  image  = local.prysm_image
  custom_args = [
    "--accept-terms-of-use",
    "--datadir",
    var.datadir_path,
    "--jwt-secret",
    var.jwt_hex_path,
    "--execution-endpoint",
    var.execution_endpoint,
    "--checkpoint-sync-url",
    var.checkpoint_sync_url,
    "--genesis-beacon-api-url",
    var.genesis_beacon_api_url,
    "--monitoring-host",
    "0.0.0.0",
    "--grpc-gateway-host",
    "0.0.0.0"
  ]
  privileged_mode      = true
  activate_tty         = true
  machine_type         = var.prysm_machine_type
  prefix               = local.service_name
  environment          = local.environment
  env_variables        = {}
  instance_name        = "prysm"
  instance_name_suffix = "cdb502a9"
  network_name         = "default"
  create_static_ip     = true
  vm_tags              = var.prysm_vm_tags
  # This has the permission to download images from Container Registry
  client_email      = var.client_email
  datadir_disk_size = var.prysm_datadir_disk_size
  volume_mounts     = local.volume_mounts
  volumes           = local.volumes
  metadata_startup_script = join("\n", [
    data.template_file.setup_jwt_auth_script.rendered,
    data.local_file.format_script.content,
  ])
}
