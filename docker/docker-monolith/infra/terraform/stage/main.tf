provider "yandex" {
  version                  = "0.35"
  service_account_key_file = var.service_account_key_file
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  zone                     = var.zone
}

module "app" {
  source           = "../modules/app"
  public_key_path  = var.public_key_path
  disk_image       = var.image_id
  subnet_id        = module.vpc.subnet_id
  private_key_path = var.private_key_path
  instance_count   = var.reddit_app_instance_count
}

module "vpc" {
  source = "../modules/vpc"
  zone   = var.zone
}

# data "yandex_compute_image" "ubuntu-image" {
#   family = "ubuntu-1804-lts"
# }

# output "ubuntu-image" {
#   value = data.yandex_compute_image.ubuntu-image.image_id
# }

# data "yandex_vpc_network" "default" {
#   name = "default"
# }

# output "default_vpc_network" {
#   value = data.yandex_vpc_network.default
# }

# output "default_vpc_network_subnet_1" {
#   value = data.yandex_vpc_network.default.subnet_ids[0]
# }
