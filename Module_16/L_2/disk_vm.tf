# 1. Создание 3 одинаковых виртуальных дисков по 1 ГБ с помощью count
resource "yandex_compute_disk" "storage_disks" {
  count = 3

  name = "storage-disk-${count.index + 1}"
  type = "network-ssd" 
  zone = var.default_zone 
  size = 1
}

# 2. Создание одиночной ВМ "storage" и динамическое подключение дисков
resource "yandex_compute_instance" "storage" {
  name        = "storage"
  platform_id = "standard-v3"
  zone        = var.default_zone

  resources {
    cores         = 2
    memory        = 1
    core_fraction = 50
  }

  boot_disk {
    initialize_params {
      image_id = "fd87v9u6g814jeosoe8v"
      size     = 10
      type     = "network-ssd"
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

  metadata = {
    serial-port-enable = 1
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }

  scheduling_policy {
    preemptible = true
  }
}
