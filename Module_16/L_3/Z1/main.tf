# Создаем облачную сеть
resource "yandex_vpc_network" "develop" {
  name = "develop"
}

# Создаем подсети
resource "yandex_vpc_subnet" "develop_a" {
  name           = "develop-ru-central1-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = ["10.0.1.0/24"]
}

resource "yandex_vpc_subnet" "develop_b" {
  name           = "develop-ru-central1-b"
  zone           = "ru-central1-e" #Не хочу менять квоты, свободна только е
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = ["10.0.2.0/24"]
}

# Вызов 1: ВМ для проекта marketing
module "marketing_vm" {
  source         = "git::https://github.com/udjin10/yandex_compute_instance.git?ref=main"
  env_name       = "marketing"
  network_id     = yandex_vpc_network.develop.id
  subnet_zones   = ["ru-central1-a"]
  subnet_ids     = [yandex_vpc_subnet.develop_a.id]
  instance_name  = "webs"
  instance_count = 1
  image_family   = "ubuntu-2004-lts"
  public_ip      = true

  labels = {
    owner   = "i.ivanov"
    project = "marketing"
  }

  metadata = {
    user-data          = data.template_file.cloudinit.rendered
    serial-port-enable = 1
  }
}

# Вызов 2: ВМ для проекта analytics
module "analytics_vm" {
  source         = "git::https://github.com/udjin10/yandex_compute_instance.git?ref=main"
  env_name       = "analytics"
  network_id     = yandex_vpc_network.develop.id
  subnet_zones   = ["ru-central1-e"]
  subnet_ids     = [yandex_vpc_subnet.develop_b.id]
  instance_name  = "web-analytics"
  instance_count = 1
  image_family   = "ubuntu-2004-lts"
  public_ip      = true

  labels = {
    owner   = "i.ivanov"
    project = "analytics"
  }

  metadata = {
    user-data          = data.template_file.cloudinit.rendered
    serial-port-enable = 1
  }
}

# Передача cloud-config и SSH-ключа в ВМ
data "template_file" "cloudinit" {
  template = file("./cloud-init.yml")
  vars = {
    ssh_key = file(var.public_key)
  }
}
