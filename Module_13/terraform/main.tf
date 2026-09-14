terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

provider "yandex" {
}

# ==================== СЕТЬ И ПОДСЕТИ ====================

resource "yandex_vpc_network" "main_vpc" {
  name = "main-vpc"
}

# Публичные подсети для балансировщика, Grafana, Kibana и Bastion
resource "yandex_vpc_subnet" "public_a" {
  name           = "public-subnet-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.main_vpc.id
  v4_cidr_blocks = ["10.10.1.0/24"]
}

resource "yandex_vpc_subnet" "public_b" {
  name           = "public-subnet-b"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.main_vpc.id
  v4_cidr_blocks = ["10.10.2.0/24"]
}

# Приватные подсети для Web-серверов, Prometheus и Elasticsearch
resource "yandex_vpc_subnet" "private_a" {
  name           = "private-subnet-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.main_vpc.id
  v4_cidr_blocks = ["10.20.1.0/24"]
  route_table_id = yandex_vpc_route_table.nat_rt.id
}

resource "yandex_vpc_subnet" "private_b" {
  name           = "private-subnet-b"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.main_vpc.id
  v4_cidr_blocks = ["10.20.2.0/24"]
  route_table_id = yandex_vpc_route_table.nat_rt.id
}

# NAT-шлюз, чтобы приватные ВМ могли скачивать пакеты (Nginx, Prometheus и т.д.)
resource "yandex_vpc_gateway" "nat_gw" {
  name = "nat-gateway"
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "nat_rt" {
  name       = "nat-route-table"
  network_id = yandex_vpc_network.main_vpc.id
  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat_gw.id
  }
}

# ==================== ГРУППЫ БЕЗОПАСНОСТИ (SECURITY GROUPS) ====================

# 1. Bastion Host SG (Разрешен только SSH снаружи)
resource "yandex_vpc_security_group" "bastion_sg" {
  name       = "bastion-sg"
  network_id = yandex_vpc_network.main_vpc.id

  ingress {
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# 2. Внутренний SSH (Разрешает SSH только из группы Bastion)
resource "yandex_vpc_security_group" "internal_ssh_sg" {
  name       = "internal-ssh-sg"
  network_id = yandex_vpc_network.main_vpc.id

  ingress {
    protocol          = "TCP"
    port              = 22
    security_group_id = yandex_vpc_security_group.bastion_sg.id
  }
}

# 3. Балансировщик ALB SG
resource "yandex_vpc_security_group" "alb_sg" {
  name       = "alb-sg"
  network_id = yandex_vpc_network.main_vpc.id

  ingress {
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    protocol          = "TCP"
    from_port         = 0
    to_port           = 65535
    predefined_target = "loadbalancer_healthchecks"
  }
  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# 4. Web-серверы SG
resource "yandex_vpc_security_group" "web_sg" {
  name       = "web-sg"
  network_id = yandex_vpc_network.main_vpc.id

  ingress {
    protocol          = "TCP"
    port              = 80
    security_group_id = yandex_vpc_security_group.alb_sg.id
  }
  ingress {
    protocol       = "TCP"
    port           = 9100 # Node Exporter
    v4_cidr_blocks = ["10.20.0.0/16", "10.10.0.0/16"]
  }
  ingress {
    protocol       = "TCP"
    port           = 4040 # Nginx Log Exporter
    v4_cidr_blocks = ["10.20.0.0/16", "10.10.0.0/16"]
  }
  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# 5. Мониторинг & Логирование SG
resource "yandex_vpc_security_group" "monitoring_logging_sg" {
  name       = "monitoring-logging-sg"
  network_id = yandex_vpc_network.main_vpc.id

  ingress {
    protocol       = "TCP"
    port           = 9090 # Prometheus
    v4_cidr_blocks = ["10.0.0.0/8"]
  }
  ingress {
    protocol       = "TCP"
    port           = 3000 # Grafana
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    protocol       = "TCP"
    port           = 9200 # Elasticsearch
    v4_cidr_blocks = ["10.0.0.0/8"]
  }
  ingress {
    protocol       = "TCP"
    port           = 5601 # Kibana
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# ==================== ВИРТУАЛЬНЫЕ МАШИНЫ ====================

data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2204-lts"
}

locals {
  ssh_metadata = {
    user-data = <<EOF
#cloud-config
users:
  - name: user7
    groups: sudo
    shell: /bin/bash
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    ssh_authorized_keys:
      - ${trimspace(file("/home/user/.ssh/yc_ed25519.pub"))}
EOF
  }
}



# Bastion Host (Публичный)
resource "yandex_compute_instance" "bastion" {
  name        = "bastion-host"
  zone        = "ru-central1-a"
  platform_id = "standard-v3"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public_a.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.bastion_sg.id]
  }

  metadata = local.ssh_metadata
}

# Web Server A (Приватный)
resource "yandex_compute_instance" "web_a" {
  name        = "web-server-a"
  zone        = "ru-central1-a"
  platform_id = "standard-v3"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.private_a.id
    security_group_ids = [
      yandex_vpc_security_group.internal_ssh_sg.id,
      yandex_vpc_security_group.web_sg.id
    ]
  }

  metadata = local.ssh_metadata
}

# Web Server B (Приватный)
resource "yandex_compute_instance" "web_b" {
  name        = "web-server-b"
  zone        = "ru-central1-b"
  platform_id = "standard-v3"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.private_b.id
    security_group_ids = [
      yandex_vpc_security_group.internal_ssh_sg.id,
      yandex_vpc_security_group.web_sg.id
    ]
  }

  metadata = local.ssh_metadata
}

# Prometheus (Приватный)
resource "yandex_compute_instance" "prometheus" {
  name        = "prometheus-server"
  zone        = "ru-central1-a"
  platform_id = "standard-v3"

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = 20
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.private_a.id
    security_group_ids = [
      yandex_vpc_security_group.internal_ssh_sg.id,
      yandex_vpc_security_group.monitoring_logging_sg.id
    ]
  }

  metadata = local.ssh_metadata
}

# Grafana (Публичный)
resource "yandex_compute_instance" "grafana" {
  name        = "grafana-server"
  zone        = "ru-central1-a"
  platform_id = "standard-v3"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public_a.id
    nat                = true
    security_group_ids = [
      yandex_vpc_security_group.internal_ssh_sg.id,
      yandex_vpc_security_group.monitoring_logging_sg.id
    ]
  }

  metadata = local.ssh_metadata
}

# Elasticsearch (Приватный)
resource "yandex_compute_instance" "elasticsearch" {
  name        = "elasticsearch-server"
  zone        = "ru-central1-a"
  platform_id = "standard-v3"

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = 30
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.private_a.id
    security_group_ids = [
      yandex_vpc_security_group.internal_ssh_sg.id,
      yandex_vpc_security_group.monitoring_logging_sg.id
    ]
  }

  metadata = local.ssh_metadata
}

# Kibana (Публичный)
resource "yandex_compute_instance" "kibana" {
  name        = "kibana-server"
  zone        = "ru-central1-a"
  platform_id = "standard-v3"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public_a.id
    nat                = true
    security_group_ids = [
      yandex_vpc_security_group.internal_ssh_sg.id,
      yandex_vpc_security_group.monitoring_logging_sg.id
    ]
  }

  metadata = local.ssh_metadata
}

# ==================== БАЛАНСИРОВЩИК (ALB) ====================

resource "yandex_alb_target_group" "web_tg" {
  name = "web-target-group"

  target {
    subnet_id  = yandex_vpc_subnet.private_a.id
    ip_address = yandex_compute_instance.web_a.network_interface.0.ip_address
  }

  target {
    subnet_id  = yandex_vpc_subnet.private_b.id
    ip_address = yandex_compute_instance.web_b.network_interface.0.ip_address
  }
}

resource "yandex_alb_backend_group" "web_bg" {
  name = "web-backend-group"

  http_backend {
    name             = "http-backend"
    port             = 80
    target_group_ids = [yandex_alb_target_group.web_tg.id]

    load_balancing_config {
      panic_threshold = 90
    }

    healthcheck {
      timeout  = "1s"
      interval = "3s"
      http_healthcheck {
        path = "/"
      }
    }
  }
}

resource "yandex_alb_http_router" "web_router" {
  name = "web-http-router"
}

resource "yandex_alb_virtual_host" "web_vhost" {
  name           = "web-virtual-host"
  http_router_id = yandex_alb_http_router.web_router.id

  route {
    name = "root-route"
    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.web_bg.id
      }
    }
  }
}

resource "yandex_alb_load_balancer" "web_alb" {
  name               = "web-alb"
  network_id         = yandex_vpc_network.main_vpc.id
  security_group_ids = [yandex_vpc_security_group.alb_sg.id]

  allocation_policy {
    location {
      zone_id   = "ru-central1-a"
      subnet_id = yandex_vpc_subnet.public_a.id
 #     security_group_ids = [yandex_vpc_security_group.alb_sg.id]
    }
    location {
      zone_id   = "ru-central1-b"
      subnet_id = yandex_vpc_subnet.public_b.id
 #     security_group_ids = [yandex_vpc_security_group.alb_sg.id]
    }
  }

  listener {
    name = "http-listener"
    endpoint {
      ports = [80]
      address {
        external_ipv4_address {}
      }
    }
    http {
      handler {
        http_router_id = yandex_alb_http_router.web_router.id
      }
    }
  }
}

# ==================== ВЫВОДЫ АДРЕСОВ ====================

output "bastion_public_ip" {
  value = yandex_compute_instance.bastion.network_interface.0.nat_ip_address
}

output "grafana_public_ip" {
  value = yandex_compute_instance.grafana.network_interface.0.nat_ip_address
}

output "kibana_public_ip" {
  value = yandex_compute_instance.kibana.network_interface.0.nat_ip_address
}

output "balancer_public_ip" {
  value = yandex_alb_load_balancer.web_alb.listener.0.endpoint.0.address.0.external_ipv4_address.0.address
}
