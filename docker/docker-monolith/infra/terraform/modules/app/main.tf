resource "yandex_compute_instance" "app" {
  count = var.instance_count
  name  = "reddit-app-${count.index + 1}"
  labels = {
    tags = "reddit-app"
  }

  resources {
    cores         = 2
    core_fraction = 5
    memory        = 2
  }

  boot_disk {
    initialize_params {
      image_id = var.disk_image
      size     = 10
    }
  }

  network_interface {
    subnet_id = var.subnet_id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.public_key_path)}"
  }

}
