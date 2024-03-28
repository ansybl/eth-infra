## Service account setup
credentials  = "../terraform-service-key.json"
client_email = "995430163323-compute@developer.gserviceaccount.com"

## Project setup
project = "dfpl-playground"
region  = "us-central1"
zone    = "us-central1-a"

## Common node setup
geth_machine_type    = "e2-standard-4"
prysm_machine_type   = "e2-highmem-2"
create_firewall_rule = true

## Geth node specific
geth_rpc_source_range = [
  # Google Cloud Platform
  "34.16.0.0/16",
  "34.66.0.0/16",
  "34.121.0.0/16",
  "34.122.0.0/16",
  "34.170.0.0/17",
  "104.197.16.0/20",
]

## Prysm node specific
# Pointing to our geth node
execution_endpoint = "http://geth-node.ansybl.io:8551"
