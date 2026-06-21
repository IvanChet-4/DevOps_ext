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

# --- Сервисный аккаунт ---

resource "yandex_iam_service_account" "sa" {
  name        = "vm-nat-sa"
  description = "Сервисный аккаунт для корректного развертывания ВМ через NAT"
}

resource "yandex_resourcemanager_folder_iam_member" "sa_viewer" {
  folder_id = var.folder_id
  role      = "viewer"
  member    = "serviceAccount:${yandex_iam_service_account.sa.id}"
}

# --- Серверы ---

resource "yandex_compute_instance" "bastion" {
  name        = "bastion-host"
  platform_id = "standard-v3"
  zone        = "ru-central1-a"

  service_account_id = yandex_iam_service_account.sa.id

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

# Создание 2 идентичных ВМ с автоматической установкой Nginx
resource "yandex_compute_instance" "web" {
  count       = 2
  name        = "web-${count.index + 1}"
  platform_id = "standard-v2"
  zone        = "ru-central1-a"

  service_account_id = yandex_iam_service_account.sa.id

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
    nat       = false # Работают в приватной сети
  }

  metadata = {
    ssh-keys  = "ubuntu:${file("~/.ssh/ed25519.pub")}"
    user-data = <<EOF
#cloud-config
users:
  - name: ubuntu
    groups: sudo
    shell: /bin/bash
    sudo: 'ALL=(ALL) NOPASSWD:ALL'
    ssh-authorized-keys:
      - ${file("~/.ssh/ed25519.pub")}
runcmd:
  - apt-get update
  - apt-get install -y nginx
  - systemctl start nginx
  - systemctl enable nginx
EOF
  }
}

resource "yandex_compute_instance" "db-server" {
  name        = "db-server"
  platform_id = "standard-v2"
  zone        = "ru-central1-a"

  service_account_id = yandex_iam_service_account.sa.id

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

# --- Создание целевой группы ---

resource "yandex_lb_target_group" "web_tg" {
  name = "web-target-group"

  dynamic "target" {
    for_each = yandex_compute_instance.web
    content {
      subnet_id = yandex_vpc_subnet.private_subnet.id
      address   = target.value.network_interface[0].ip_address
    }
  }
}

# --- Создание сетевого балансировщика нагрузки ---

resource "yandex_lb_network_load_balancer" "web_lb" {
  name = "web-load-balancer"

  listener {
    name        = "http-listener"
    port        = 80
    target_port = 80
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_lb_target_group.web_tg.id

    healthcheck {
      name = "http-healthcheck"
      # Ошибка исправлена: port перенесен внутрь http_options
      http_options {
        port = 80
        path = "/"
      }
    }
  }
}

# --- Вывод ---

output "bastion_ip" {
  value = yandex_compute_instance.bastion.network_interface[0].nat_ip_address
}

output "web_internal_ips" {
  value = yandex_compute_instance.web[*].network_interface[0].ip_address
}

output "db-server_internal_ip" {
  value = yandex_compute_instance.db-server.network_interface[0].ip_address
}

output "load_balancer_public_ip" {
  value = one(one(yandex_lb_network_load_balancer.web_lb.listener).external_address_spec).address
}
