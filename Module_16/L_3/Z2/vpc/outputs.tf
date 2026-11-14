output "subnet" {
  description = "Полная информация о созданной подсети yandex_vpc_subnet"
  value       = yandex_vpc_subnet.subnet
}

output "network" {
  description = "Полная информация о созданной сети yandex_vpc_network"
  value       = yandex_vpc_network.network
}
