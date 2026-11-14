terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">=1.12.0"
}

provider "yandex" {
  cloud_id                 = "b1gn***"
  folder_id                = "b1gm***"
  service_account_key_file = file("~/M16/L3/Z1/.authorized_key.json")
  zone                     = "ru-central1-a" 
}
