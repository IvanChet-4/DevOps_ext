<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.12.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_yandex"></a> [yandex](#provider\_yandex) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [yandex_vpc_network.network](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/vpc_network) | resource |
| [yandex_vpc_subnet.subnet](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/vpc_subnet) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_cidr"></a> [cidr](#input\_cidr) | Блок IP-адресов подсети в формате CIDR (v4\_cidr\_blocks) | `string` | n/a | yes |
| <a name="input_env_name"></a> [env\_name](#input\_env\_name) | Название сети и окружения (например, develop) | `string` | n/a | yes |
| <a name="input_zone"></a> [zone](#input\_zone) | Зона доступности Yandex Cloud (например, ru-central1-a) | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_network"></a> [network](#output\_network) | Полная информация о созданной сети yandex\_vpc\_network |
| <a name="output_subnet"></a> [subnet](#output\_subnet) | Полная информация о созданной подсети yandex\_vpc\_subnet |
<!-- END_TF_DOCS -->
