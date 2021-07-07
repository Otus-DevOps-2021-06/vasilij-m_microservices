output "default_vpc_network" {
  value = data.yandex_vpc_network.default.id
}

output "default_vpc_network_central1_a_subnet" {
  value = data.yandex_vpc_subnet.default_central1_a.subnet_id
}

output "ubuntu_image" {
  value = data.yandex_compute_image.ubuntu-image.image_id
}
