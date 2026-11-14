variable "env_name" {
  type        = string
  description = "Название сети и окружения (например, develop)"
}

variable "zone" {
  type        = string
  description = "Зона доступности Yandex Cloud (например, ru-central1-a)"
}

variable "cidr" {
  type        = string
  description = "Блок IP-адресов подсети в формате CIDR (v4_cidr_blocks)"
}
