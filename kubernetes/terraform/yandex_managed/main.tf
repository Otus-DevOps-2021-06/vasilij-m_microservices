terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

provider "yandex" {
  service_account_key_file = var.service_account_key_file
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  zone                     = var.zone
}

data "yandex_vpc_subnet" "default_central1_a" {
  name = "default-ru-central1-a"
}

data "yandex_vpc_network" "default" {
  name = "default"
}

resource "yandex_kubernetes_cluster" "reddit_cluster" {
  name = "reddit-cluster"

  network_id = data.yandex_vpc_network.default.id

  master {
    version = "1.19"
    zonal {
      zone      = var.zone
      subnet_id = data.yandex_vpc_subnet.default_central1_a.id
    }

    public_ip = true

    maintenance_policy {
      auto_upgrade = true
    }
  }

  service_account_id      = var.service_account_id
  node_service_account_id = var.service_account_id

  release_channel         = "RAPID"
  network_policy_provider = "CALICO"

}

resource "yandex_kubernetes_node_group" "reddit_group" {
  cluster_id = yandex_kubernetes_cluster.reddit_cluster.id
  name       = "reddit-group"
  version    = "1.19"

  instance_template {
    platform_id = "standard-v2"

    metadata = {
      ssh-keys = "ubuntu:${file(var.public_key_path)}"
    }

    network_interface {
      nat        = true
      subnet_ids = [data.yandex_vpc_subnet.default_central1_a.id]
    }

    resources {
      memory = 4
      cores  = 4
    }

    boot_disk {
      type = "network-ssd"
      size = 64
    }

    scheduling_policy {
      preemptible = true
    }
  }

  scale_policy {
    auto_scale {
      min     = 2
      max     = 3
      initial = 2
    }
  }

  allocation_policy {
    location {
      zone = var.zone
    }
  }

  maintenance_policy {
    auto_upgrade = true
    auto_repair  = true
  }

}
