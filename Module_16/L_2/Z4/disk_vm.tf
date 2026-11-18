# 1. Создание 3 одинаковых виртуальных дисков по 1 ГБ с помощью count
resource "yandex_compute_disk" "storage_disks" {
  count = var.storage_disk_count

  name = "storage-disk-${count.index + 1}"
  type = var.storage_disk_type
  zone = var.default_zone 
  size = var.storage_disk_size
}

# 2. Создание одиночной ВМ "storage" и динамическое подключение дисков
resource "yandex_compute_instance" "storage" {
  name        = "storage"
  platform_id = var.web_platform_id
  zone        = var.default_zone

  resources {
    cores         = var.web_resources.cores
    memory        = var.web_resources.memory
    core_fraction = var.web_resources.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.os_image.id
      size     = var.boot_disk_size
      type     = var.storage_disk_type
    }
  }

  # Динамическое подключение всех 3 созданных дисков через for_each
  dynamic "secondary_disk" {
    for_each = yandex_compute_disk.storage_disks
    content {
      disk_id = secondary_disk.value.id
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.develop.id
    nat       = true
  }

  metadata = merge(var.vms_metadata, {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  })

  scheduling_policy {
    preemptible = true
  }
}
