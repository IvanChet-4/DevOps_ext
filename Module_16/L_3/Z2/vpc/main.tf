# Вызов локального модуля VPC для первой зоны
module "vpc_dev" {
  source   = "./vpc"
  env_name = "develop"
  zone     = "ru-central1-a"
  cidr     = "10.0.1.0/24"
}

# Вызов локального модуля VPC для второй зоны
module "vpc_prod" {
  source   = "./vpc"
  env_name = "production"
  zone     = "ru-central1-e"
  cidr     = "10.0.2.0/24"
}

# Вызов 1: ВМ для проекта marketing
module "marketing_vm" {
  source         = "git::https://github.com/udjin10/yandex_compute_instance.git?ref=main"
  env_name       = "marketing"
  network_id     = module.vpc_dev.subnet.network_id
  subnet_zones   = [module.vpc_dev.subnet.zone]
  subnet_ids     = [module.vpc_dev.subnet.id]
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
  network_id     = module.vpc_prod.subnet.network_id
  subnet_zones   = [module.vpc_prod.subnet.zone]
  subnet_ids     = [module.vpc_prod.subnet.id]
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
