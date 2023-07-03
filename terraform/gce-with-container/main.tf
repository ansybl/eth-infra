locals {
  # https://www.terraform.io/docs/language/values/locals.html
  instance_name = format("%s-%s", var.instance_name, substr(md5(module.gce-container.container.image), 0, 8))

  env_variables = [for var_name, var_value in var.env_variables : {
    name  = var_name
    value = var_value
  }]
}

####################
##### CONTAINER SETUP

module "gce-container" {
  # https://github.com/terraform-google-modules/terraform-google-container-vm
  source  = "terraform-google-modules/container-vm/google"
  version = "3.1.0"

  container = {
    image        = var.image
    command      = var.custom_command
    args         = var.custom_args
    env          = local.env_variables
    volumeMounts = var.volume_mounts
    securityContext = {
      privileged : var.privileged_mode
    }
    tty : var.activate_tty
  }

  volumes = var.volumes

  restart_policy = "Always"
}

####################
##### COMPUTE ENGINE

resource "google_compute_disk" "boot" {
  name  = "${var.prefix}-${local.instance_name}-boot-disk-${var.environment}"
  image = module.gce-container.source_image
  size  = 10
  type  = "pd-balanced"
  labels = {
    container-vm  = module.gce-container.vm_container_label
    prefix        = var.prefix
    instance_name = local.instance_name
  }
  lifecycle {
    ignore_changes = [
      # we don't want the Container-Optimized OS changes to force a redeployment of our VM without our consent
      image,
    ]
  }
}

resource "google_compute_disk" "datadir" {
  name = "${var.prefix}-${local.instance_name}-datadir-disk-${var.environment}"
  type = "pd-balanced"
  size = var.datadir_disk_size
}

# make automatic snapshot
resource "google_compute_resource_policy" "bimonthly" {
  name = "${var.prefix}-${local.instance_name}-resource-policy-${var.environment}"
  snapshot_schedule_policy {
    schedule {
      daily_schedule {
        days_in_cycle = 14
        start_time    = "04:00"
      }
    }
    retention_policy {
      max_retention_days    = 30
      on_source_disk_delete = "KEEP_AUTO_SNAPSHOTS"
    }
    snapshot_properties {
      labels = {
        prefix        = var.prefix
        instance_name = local.instance_name
        environment   = var.environment
      }
    }
  }
}

resource "google_compute_disk_resource_policy_attachment" "snapshot_attachment_bimonthly" {
  name = google_compute_resource_policy.bimonthly.name
  disk = google_compute_disk.datadir.name
}

resource "google_compute_instance" "this" {
  name         = "${var.prefix}-${local.instance_name}-${var.environment}"
  machine_type = var.machine_type
  # If true, allows Terraform to stop the instance to update its properties.
  allow_stopping_for_update = true
  tags                      = var.vm_tags

  boot_disk {
    source = google_compute_disk.boot.self_link
  }

  attached_disk {
    source      = google_compute_disk.datadir.self_link
    device_name = google_compute_disk.datadir.name
    mode        = "READ_WRITE"
  }

  network_interface {
    network    = var.network_name
    network_ip = var.create_static_ip ? google_compute_address.static_internal.address : null
    access_config {
      nat_ip = var.create_static_ip ? google_compute_address.static.address : null
    }
  }

  metadata = {
    gce-container-declaration = module.gce-container.metadata_value
    google-logging-enabled    = var.enable_gcp_logging
    google-monitoring-enabled = var.enable_gcp_monitoring
  }

  labels = {
    container-vm  = module.gce-container.vm_container_label
    prefix        = var.prefix
    instance_name = local.instance_name
  }

  service_account {
    email = var.client_email
    scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  lifecycle {
    ignore_changes = [
      # we don't want the Container-Optimized OS changes to force a redeployment of our VM without our consent
      boot_disk[0].initialize_params[0].image,
    ]
  }

  metadata_startup_script = var.metadata_startup_script
}
