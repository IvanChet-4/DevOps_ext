# Домашнее задание к занятию  «Очереди RabbitMQ»

### Задание 1. Установка RabbitMQ

Используя Vagrant или VirtualBox, создайте виртуальную машину и установите RabbitMQ.
Добавьте management plug-in и зайдите в веб-интерфейс.

*Итогом выполнения домашнего задания будет приложенный скриншот веб-интерфейса RabbitMQ.*

#### Решение:  

Создаем файл:  
[docker-compose.yml](https://github.com/IvanChet-4/DevOps_ext/blob/main/Module_10/L_4/docker-compose.yml)  

Запускаем:  

```  
docker compose up -d
```  

<img width="1509" height="122" alt="image" src="https://github.com/user-attachments/assets/fa21c2a2-27c9-48b8-a99e-c5a9829bbc47" />  


<img width="1434" height="734" alt="image" src="https://github.com/user-attachments/assets/ac8853e7-0e18-4510-8ec5-e994e82c1340" />  


---

### Задание 2. Отправка и получение сообщений

Используя приложенные скрипты, проведите тестовую отправку и получение сообщения.
Для отправки сообщений необходимо запустить скрипт producer.py.

Для работы скриптов вам необходимо установить Python версии 3 и библиотеку Pika.
Также в скриптах нужно указать IP-адрес машины, на которой запущен RabbitMQ, заменив localhost на нужный IP.

```shell script
$ pip install pika
```

Зайдите в веб-интерфейс, найдите очередь под названием hello и сделайте скриншот.
После чего запустите второй скрипт consumer.py и сделайте скриншот результата выполнения скрипта

*В качестве решения домашнего задания приложите оба скриншота, сделанных на этапе выполнения.*

Для закрепления материала можете попробовать модифицировать скрипты, чтобы поменять название очереди и отправляемое сообщение.

#### Решение:   

Ставим пакет pika:  

```  
sudo apt install python3-pika
```  

<img width="956" height="402" alt="image" src="https://github.com/user-attachments/assets/f6a4580b-a454-4283-8e43-19d6d4a2c27a" />

Поменял в скриптах localhost.  

Запустил первый скрипт:  

```
sudo python3 producer.py
```  

<img width="1104" height="606" alt="image" src="https://github.com/user-attachments/assets/afaa1cd0-61ba-4bde-99cc-4963d7d40727" />

Из за особенностей версий pika пришлось поправить скрипт consumer.py:  

```  
Вместо:
channel.basic_consume(callback, queue='hello', no_ack=True)

Поставил:
channel.basic_consume(queue='hello', on_message_callback=callback, auto_ack=True)

```

Обновленный файл:  

[consumer.py](https://github.com/IvanChet-4/DevOps_ext/blob/main/Module_10/L_4/consumer.py)  


Запуск второго скрипта:  

```  
sudo python3 consumer.py
```    

<img width="548" height="71" alt="image" src="https://github.com/user-attachments/assets/5587359f-bd2c-4a5f-944a-5d6c8dd8081e" />


---

### Задание 3. Подготовка HA кластера

Используя Vagrant или VirtualBox, создайте вторую виртуальную машину и установите RabbitMQ.
Добавьте в файл hosts название и IP-адрес каждой машины, чтобы машины могли видеть друг друга по имени.

Пример содержимого hosts файла:
```shell script
$ cat /etc/hosts
192.168.0.10 rmq01
192.168.0.11 rmq02
```
После этого ваши машины могут пинговаться по имени.

Затем объедините две машины в кластер и создайте политику ha-all на все очереди.

*В качестве решения домашнего задания приложите скриншоты из веб-интерфейса с информацией о доступных нодах в кластере и включённой политикой.*

Также приложите вывод команды с двух нод:

```shell script
$ rabbitmqctl cluster_status
```

Для закрепления материала снова запустите скрипт producer.py и приложите скриншот выполнения команды на каждой из нод:

```shell script
$ rabbitmqadmin get queue='hello'
```

После чего попробуйте отключить одну из нод, желательно ту, к которой подключались из скрипта, затем поправьте параметры подключения в скрипте consumer.py на вторую ноду и запустите его.

*Приложите скриншот результата работы второго скрипта.*

#### Решение:  

<img width="1457" height="710" alt="image" src="https://github.com/user-attachments/assets/3f2c476e-2de4-48bd-9652-6254ac4c74ce" />  

<img width="1249" height="684" alt="image" src="https://github.com/user-attachments/assets/9120a599-c5a7-4123-94ed-8d0ff8b898a8" />

<img width="1323" height="706" alt="image" src="https://github.com/user-attachments/assets/d020b216-8b63-48b8-89e9-81f7bdae19ef" />

<img width="637" height="303" alt="image" src="https://github.com/user-attachments/assets/cb4d035b-8e82-4de2-9c94-176eb178dc66" />  

<img width="687" height="542" alt="image" src="https://github.com/user-attachments/assets/c2ce8595-7579-43c6-8638-3b6cd894ede4" />  

<img width="1266" height="156" alt="image" src="https://github.com/user-attachments/assets/5d58d2be-c4d0-4e82-8ae6-4ed605dd201b" />  

<img width="1297" height="132" alt="image" src="https://github.com/user-attachments/assets/1ed8ad7d-220c-42ca-8ce0-acb0dc4982ab" />  

Отключил одну ноду:  

<img width="1568" height="787" alt="image" src="https://github.com/user-attachments/assets/8b9848b0-fb5a-4e61-8400-ff7cf6e491d0" />  



## Дополнительные задания (со звёздочкой*)
Эти задания дополнительные, то есть не обязательные к выполнению, и никак не повлияют на получение вами зачёта по этому домашнему заданию. Вы можете их выполнить, если хотите глубже шире разобраться в материале.

### * Задание 4. Ansible playbook

Напишите плейбук, который будет производить установку RabbitMQ на любое количество нод и объединять их в кластер.
При этом будет автоматически создавать политику ha-all.

*Готовый плейбук разместите в своём репозитории.*

#### Решение:  

Создаем файлы:  

[ansible.cfg](https://github.com/IvanChet-4/DevOps_ext/blob/main/Module_10/L_4/Z_4/ansible.cfg)  

[deploy_rabbitmq.yml](https://github.com/IvanChet-4/DevOps_ext/blob/main/Module_10/L_4/Z_4/deploy_rabbitmq.yml)  

[hosts.ini](https://github.com/IvanChet-4/DevOps_ext/blob/main/Module_10/L_4/Z_4/hosts.ini)  

Ставим пакеты:  

sudo apt update && sudo apt install -y sshpass   

sudo apt install ansible-core  

Ставим коллекцию:  

ansible-galaxy collection install community.rabbitmq  

Запускаем:  

ansible-playbook -i hosts.ini deploy_rabbitmq.yml  -k -K  

Создаем пользователя с правами:  

sudo rabbitmqctl add_user admin adminpass  

sudo rabbitmqctl set_user_tags admin administrator  

sudo rabbitmqctl set_permissions -p / admin ".*" ".*" ".*"  

<img width="1216" height="335" alt="image" src="https://github.com/user-attachments/assets/f7fd8746-7d74-4e19-86e1-fbca9285fcec" />  

<img width="1359" height="852" alt="image" src="https://github.com/user-attachments/assets/861241bd-f34c-4c7c-9062-22b892e88b8b" />  

<img width="1033" height="611" alt="image" src="https://github.com/user-attachments/assets/d8e73cab-484a-4f89-9054-bc41dfb2a67b" />

<img width="1457" height="710" alt="image" src="https://github.com/user-attachments/assets/12bedd10-661f-4c5f-a40b-5830e7f89583" />

<img width="1249" height="684" alt="image" src="https://github.com/user-attachments/assets/61600b49-d548-4a88-8d16-567a3bef4ec1" />
