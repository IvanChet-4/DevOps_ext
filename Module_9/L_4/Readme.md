# «Отказоустойчивость в облаке»

### Цель задания

В результате выполнения этого задания вы научитесь:  
1. Конфигурировать отказоустойчивый кластер в облаке с использованием различных функций отказоустойчивости. 
2. Устанавливать сервисы из конфигурации инфраструктуры.

------

### Чеклист готовности к домашнему заданию

1. Создан аккаунт на YandexCloud.  
2. Создан новый OAuth-токен.  
3. Установлено программное обеспечение  Terraform.   


### Инструменты и дополнительные материалы, которые пригодятся для выполнения задания

1. [Документация сетевого балансировщика нагрузки](https://cloud.yandex.ru/docs/network-load-balancer/quickstart)

 ---

## Задание 1 

Возьмите за основу [решение к заданию 1 из занятия «Подъём инфраструктуры в Яндекс Облаке»](https://github.com/netology-code/sdvps-homeworks/blob/main/7-03.md#задание-1).

1. Теперь вместо одной виртуальной машины сделайте terraform playbook, который:

- создаст 2 идентичные виртуальные машины. Используйте аргумент [count](https://www.terraform.io/docs/language/meta-arguments/count.html) для создания таких ресурсов;
- создаст [таргет-группу](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/lb_target_group). Поместите в неё созданные на шаге 1 виртуальные машины;
- создаст [сетевой балансировщик нагрузки](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/lb_network_load_balancer), который слушает на порту 80, отправляет трафик на порт 80 виртуальных машин и http healthcheck на порт 80 виртуальных машин.

Рекомендуем изучить [документацию сетевого балансировщика нагрузки](https://cloud.yandex.ru/docs/network-load-balancer/quickstart) для того, чтобы было понятно, что вы сделали.

2. Установите на созданные виртуальные машины пакет Nginx любым удобным способом и запустите Nginx веб-сервер на порту 80.

3. Перейдите в веб-консоль Yandex Cloud и убедитесь, что: 

- созданный балансировщик находится в статусе Active,

 <img width="1293" height="315" alt="image" src="https://github.com/user-attachments/assets/917c96fb-945f-48d2-8dcc-5e0521cec7e4" />
 
- обе виртуальные машины в целевой группе находятся в состоянии healthy.

<img width="1184" height="325" alt="image" src="https://github.com/user-attachments/assets/4fe12372-abf8-4a20-9898-5b79cb8ae47a" />

<img width="841" height="438" alt="image" src="https://github.com/user-attachments/assets/fe6e62c1-c6c1-4977-8a11-beb9039b73c3" />

4. Сделайте запрос на 80 порт на внешний IP-адрес балансировщика и убедитесь, что вы получаете ответ в виде дефолтной страницы Nginx.

<img width="1297" height="520" alt="image" src="https://github.com/user-attachments/assets/ffb796dd-dc1a-4436-9120-a64ab5cf55f8" />  

  
#### Решение  
  
*В качестве результата пришлите:*  

*1. Terraform Playbook.*  
  
[main.tf](https://github.com/IvanChet-4/DevOps_ext/blob/main/Module_9/L_4/Terraform/main.tf)  
[variables.tf](https://github.com/IvanChet-4/DevOps_ext/blob/main/Module_9/L_4/Terraform/variables.tf)  
  
*2. Скриншот статуса балансировщика и целевой группы.*  

 <img width="1293" height="315" alt="image" src="https://github.com/user-attachments/assets/917c96fb-945f-48d2-8dcc-5e0521cec7e4" />  
   
<img width="1218" height="900" alt="image" src="https://github.com/user-attachments/assets/2aa8e80f-d028-40c5-ae87-e3cce94fcc09" />  
  
<img width="1620" height="914" alt="image" src="https://github.com/user-attachments/assets/7b642c14-d892-44b4-9d7d-d30579d928d4" />  
  
*3. Скриншот страницы, которая открылась при запросе IP-адреса балансировщика.*  


<img width="1653" height="548" alt="image" src="https://github.com/user-attachments/assets/a6a150f8-28c8-4ad7-aa7d-9c70c6180eb2" />



---

## Задания со звёздочкой*
Эти задания дополнительные. Выполнять их не обязательно. На зачёт это не повлияет. Вы можете их выполнить, если хотите глубже разобраться в материале.

---

## Задание 2*

1. Теперь вместо создания виртуальных машин создайте [группу виртуальных машин с балансировщиком нагрузки](https://cloud.yandex.ru/docs/compute/operations/instance-groups/create-with-balancer).

2. Nginx нужно будет поставить тоже автоматизированно. Для этого вам нужно будет подложить файл установки Nginx в user-data-ключ [метадаты](https://cloud.yandex.ru/docs/compute/concepts/vm-metadata) виртуальной машины.

- [Пример файла установки Nginx](https://github.com/nar3k/yc-public-tasks/blob/master/terraform/metadata.yaml).
- [Как подставлять файл в метадату виртуальной машины.](https://github.com/nar3k/yc-public-tasks/blob/a6c50a5e1d82f27e6d7f3897972adb872299f14a/terraform/main.tf#L38)

3. Перейдите в веб-консоль Yandex Cloud и убедитесь, что: 

- созданный балансировщик находится в статусе Active,
- обе виртуальные машины в целевой группе находятся в состоянии healthy.

4. Сделайте запрос на 80 порт на внешний IP-адрес балансировщика и убедитесь, что вы получаете ответ в виде дефолтной страницы Nginx.

*В качестве результата пришлите*

*1. Terraform Playbook.*

*2. Скриншот статуса балансировщика и целевой группы.*

*3. Скриншот страницы, которая открылась при запросе IP-адреса балансировщика.*

<!-- [//] https://github.com/netology-code/sflt-homeworks/blob/main/4.md -->
