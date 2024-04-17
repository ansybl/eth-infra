resource "google_compute_firewall" "allow_tag_geth_auth_rpc" {
  count         = var.create_firewall_rule ? 1 : 0
  name          = "${var.prefix}-${local.instance_name}-ingress-tag-geth-auth-rpc-${var.environment}"
  description   = "Ingress to allow geth auth RPC ports to machines with the 'geth-auth-rpc' tag"
  network       = var.network_name
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["geth-auth-rpc"]
  allow {
    protocol = "tcp"
    ports    = [var.geth_auth_rpc_port]
  }
}

resource "google_compute_firewall" "allow_tag_geth_http_rpc" {
  count         = var.create_firewall_rule ? 1 : 0
  name          = "${var.prefix}-${local.instance_name}-ingress-tag-geth-http-rpc-${var.environment}"
  description   = "Ingress to allow geth HTTP RPC ports to machines with the 'geth-http-rpc' tag"
  network       = var.network_name
  source_ranges = var.geth_rpc_source_range
  target_tags   = ["geth-http-rpc"]
  allow {
    protocol = "tcp"
    ports    = [var.geth_http_rpc_port]
  }
}

resource "google_compute_firewall" "allow_tag_geth_ws_rpc" {
  count         = var.create_firewall_rule ? 1 : 0
  name          = "${var.prefix}-${local.instance_name}-ingress-tag-geth-ws-rpc-${var.environment}"
  description   = "Ingress to allow geth HTTP WS RPC ports to machines with the 'geth-ws-rpc' tag"
  network       = var.network_name
  source_ranges = var.geth_rpc_source_range
  target_tags   = ["geth-ws-rpc"]
  allow {
    protocol = "tcp"
    ports    = [var.geth_ws_rpc_port]
  }
}

resource "google_compute_firewall" "allow_tag_geth_p2p" {
  count         = var.create_firewall_rule ? 1 : 0
  name          = "${var.prefix}-${local.instance_name}-ingress-tag-geth-p2p-${var.environment}"
  description   = "Ingress to allow geth P2P TCP and UDP ports to machines with the 'geth-p2p' tag"
  network       = var.network_name
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["geth-p2p"]
  allow {
    protocol = "tcp"
    ports    = [var.geth_p2p_port]
  }
  allow {
    protocol = "udp"
    ports    = [var.geth_p2p_port]
  }
}

resource "google_compute_firewall" "allow_tag_geth_metrics" {
  count         = var.create_firewall_rule ? 1 : 0
  name          = "${var.prefix}-${local.instance_name}-ingress-tag-geth-metrics-${var.environment}"
  description   = "Ingress to allow geth metrics port to machines with the 'geth-metrics' tag"
  network       = var.network_name
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["geth-metrics"]
  allow {
    protocol = "tcp"
    ports    = [var.geth_metrics_port]
  }
}

resource "google_compute_firewall" "allow_tag_prysm_rpc" {
  count         = var.create_firewall_rule ? 1 : 0
  name          = "${var.prefix}-${local.instance_name}-ingress-tag-prysm-rpc-${var.environment}"
  description   = "Ingress to allow beacon node RPC ports to machines with the 'prysm-rpc' tag"
  network       = var.network_name
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["prysm-rpc"]
  allow {
    protocol = "tcp"
    ports    = [var.prysm_rpc_port]
  }
}

resource "google_compute_firewall" "allow_tag_prysm_json_rpc" {
  count         = var.create_firewall_rule ? 1 : 0
  name          = "${var.prefix}-${local.instance_name}-ingress-tag-prysm-json-rpc-${var.environment}"
  description   = "Ingress to allow beacon node json RPC ports to machines with the 'prysm-rpc' tag"
  network       = var.network_name
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["prysm-rpc"]
  allow {
    protocol = "tcp"
    ports    = [var.prysm_json_rpc_port]
  }
}

resource "google_compute_firewall" "allow_tag_prysm_p2p_udp" {
  count         = var.create_firewall_rule ? 1 : 0
  name          = "${var.prefix}-${local.instance_name}-ingress-tag-prysm-p2p-udp-${var.environment}"
  description   = "Ingress to allow beacon node RPC P2P UDP ports to machines with the 'prysm-p2p-udp' tag"
  network       = var.network_name
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["prysm-p2p-udp"]
  allow {
    protocol = "udp"
    ports    = [var.prysm_p2p_udp_port]
  }
}

resource "google_compute_firewall" "allow_tag_prysm_p2p" {
  count         = var.create_firewall_rule ? 1 : 0
  name          = "${var.prefix}-${local.instance_name}-ingress-tag-prysm-p2p-${var.environment}"
  description   = "Ingress to allow beacon node RPC P2P ports to machines with the 'prysm-p2p' tag"
  network       = var.network_name
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["prysm-p2p"]
  allow {
    protocol = "tcp"
    ports    = [var.prysm_rpc_port]
  }
}

resource "google_compute_firewall" "allow_tag_prysm_metrics" {
  count         = var.create_firewall_rule ? 1 : 0
  name          = "${var.prefix}-${local.instance_name}-ingress-tag-prysm-metrics-${var.environment}"
  description   = "Ingress to allow prysm metrics port to machines with the 'prysm-metrics' tag"
  network       = var.network_name
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["prysm-metrics"]
  allow {
    protocol = "tcp"
    ports    = [var.prysm_metrics_port]
  }
}

resource "google_compute_address" "static" {
  provider = google-beta
  name     = "${var.prefix}-${local.instance_name}-address-${var.environment}"
  labels = merge(tomap({
    prefix        = var.prefix
    instance_name = local.instance_name
    }),
  )
}

resource "google_compute_address" "static_internal" {
  provider     = google-beta
  name         = "${var.prefix}-${local.instance_name}-internal-address-${var.environment}"
  address_type = "INTERNAL"
  labels = merge(tomap({
    prefix        = var.prefix
    instance_name = local.instance_name
    }),
  )
}
