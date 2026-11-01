packer {
  required_plugins {
    yandex = {
      version = ">= 1.1.2"
      source  = "github.com/hashicorp/yandex"
    }
  }
}


locals {
  my_folder_id             = "b1gm****"
  my_subnet_id             = "e9ba****"
  service_account_key_file = "key.json"
}

source "yandex" "debian11_base" {
  folder_id                = local.my_folder_id
  subnet_id                = local.my_subnet_id
  service_account_key_file = local.service_account_key_file

  # Берем за основу официальный чистый Debian 11
  source_image_family = "debian-11"
  
  # Настройки итогового образа
  image_name        = "custom-debian-11-v1"
  image_family      = "my-custom-images"
  image_description = "Debian 11 image with custom setup"

  # Технические параметры сборщика
  zone             = "ru-central1-a"
  ssh_username     = "debian"
  use_ipv4_nat     = "true"
}

build {
  sources = ["source.yandex.debian11_base"]

  #Тест
  provisioner "shell" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get upgrade -y",
      "sudo apt-get install -y curl htop"
    ]
  }
}
