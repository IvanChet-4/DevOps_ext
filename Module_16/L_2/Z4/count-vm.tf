resource "yandex_compute_instance" "web" {
  count = var.web_count

  name        = "web-${count.index + 1}"
  platform_id = var.web_platform_id

  resources {
    cores         = var.web_resources.cores
    memory        = var.web_resources.memory
    core_fraction = var.web_resources.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.os_image.id
      size = yandex_compute_instance.storage.boot_disk[0].initialize_params[0].size
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.develop.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.example.id]
  }

  metadata = merge(var.vms_metadata, {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  })

  scheduling_policy {
    preemptible = true
  }

  # Гарантируем создание ПОСЛЕ ВМ из for_each-vm.tf
  depends_on = [yandex_compute_instance.db]
}
