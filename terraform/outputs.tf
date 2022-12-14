output "geth_ip" {
  value = module.gce_geth_worker_container.google_compute_instance_ip
}

output "prysm_ip" {
  value = module.gce_prysm_worker_container.google_compute_instance_ip
}
