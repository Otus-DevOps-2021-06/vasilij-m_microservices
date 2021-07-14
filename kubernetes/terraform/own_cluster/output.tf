output "k8s_master_external_ip_address" {
  value = [
    for instance in yandex_compute_instance.k8s-master :
    instance.network_interface.0.nat_ip_address
  ]
}

output "k8s_worker_external_ip_address" {
  value = [
    for instance in yandex_compute_instance.k8s-worker :
    instance.network_interface.0.nat_ip_address
  ]
}

# output "default_vpc_network" {
#   value = data.yandex_vpc_network.default
# }

# output "default_vpc_network_subnet_1" {
#   value = data.yandex_vpc_network.default.subnet_ids[0]
# }

# output "default_vpc_network_central1_a_subnet" {
#   value = data.yandex_vpc_subnet.default_central1_a.subnet_id
# }

# output "ubuntu-image" {
#   value = data.yandex_compute_image.ubuntu-image.image_id
# }
