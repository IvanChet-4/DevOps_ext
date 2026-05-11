terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

provider "yandex" {
  token     = var.yandex_cloud_token
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = "ru-central1-a"
}

# --- Сеть и NAT-шлюз ---

resource "yandex_vpc_network" "main" {
  name = "web-network"
}

# Создаем NAT-шлюз
resource "yandex_vpc_gateway" "nat_gateway" {
  name = "egress-gateway"
  shared_egress_gateway {}
}

# Создаем таблицу маршрутизации для выхода в интернет через NAT
resource "yandex_vpc_route_table" "private_rt" {
  network_id = yandex_vpc_network.main.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat_gateway.id
  }
}

resource "yandex_vpc_subnet" "public_subnet" {
  name           = "public-subnet"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = ["10.0.1.0/24"]
}

resource "yandex_vpc_subnet" "private_subnet" {
  name           = "private-subnet"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = ["10.0.2.0/24"]
  # Привязываем таблицу маршрутизации к приватной подсети
  route_table_id = yandex_vpc_route_table.private_rt.id
}

# --- Серверы ---

resource "yandex_compute_instance" "bastion" {
  name        = "bastion-host"
  platform_id = "standard-v3"
  zone        = "ru-central1-a"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd89mp67446a6rcc4s08"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.public_subnet.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/ed25519.pub")}"
  }
}

resource "yandex_compute_instance" "web-a" {
  name        = "web-a"
  platform_id = "standard-v2"
  zone        = "ru-central1-a"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd89mp67446a6rcc4s08"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.private_subnet.id
    nat       = false
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/ed25519.pub")}"
  }
}

resource "yandex_compute_instance" "web-b" {
  name        = "web-b"
  platform_id = "standard-v2"
  zone        = "ru-central1-a"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd89mp67446a6rcc4s08"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.private_subnet.id
    nat       = false
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/ed25519.pub")}"
  }
}

# --- Вывод ---

output "bastion_ip" {
  value = yandex_compute_instance.bastion.network_interface[0].nat_ip_address
}

output "web_a_internal_ip" {
  value = yandex_compute_instance.web-a.network_interface[0].ip_address
}

output "web_b_internal_ip" {
  value = yandex_compute_instance.web-b.network_interface[0].ip_address
}
