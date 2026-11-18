###cloud vars
variable "token" {
  type        = string
  description = "OAuth-token; https://cloud.yandex.ru/docs/iam/concepts/authorization/oauth-token"
}

variable "cloud_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
}

variable "folder_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
}

variable "default_zone" {
  type        = string
  default     = "ru-central1-a"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}
variable "default_cidr" {
  type        = list(string)
  default     = ["10.0.1.0/24"]
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}

variable "vpc_name" {
  type        = string
  default     = "develop"
  description = "VPC network&subnet name"
}

variable "os_family" {
  type        = string
  default     = "ubuntu-2404-lts-oslogin"
  description = "iso"
}

variable "web_count" {
  description = "Количество веб-серверов"
  type        = number
  default     = 2
}

variable "web_platform_id" {
  description = "Платформа ВМ"
  type        = string
  default     = "standard-v3"
}

variable "web_resources" {
  description = "Вычислительные ресурсы для веб-серверов"
  type = object({
    cores         = number
    memory        = number
    core_fraction = number
  })
  default = {
    cores         = 2
    memory        = 1
    core_fraction = 20
  }
}

variable "vms_metadata" {
  description = "Метаданные"
  type        = map(any)
  default = {
    serial-port-enable = 1
  }
}

variable "boot_disk_size" {
  description = "Размер загрузочного диска ВМ в ГБ"
  type        = number
  default     = 10
}

variable "storage_disk_count" {
  description = "Количество дополнительных виртуальных дисков"
  type        = number
  default     = 3
}

variable "storage_disk_type" {
  description = "Тип дополнительных виртуальных дисков"
  type        = string
  default     = "network-hdd"
}

variable "storage_disk_size" {
  description = "Размер каждого дополнительного диска в ГБ"
  type        = number
  default     = 1
}

variable "vm_core_fraction" {
  description = "Гарантированная доля vCPU в процентах"
  type        = number
  default     = 20
}
