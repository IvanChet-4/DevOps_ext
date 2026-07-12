# Домашнее задание к занятию «ELK»

## Дополнительные ресурсы

При выполнении задания используйте дополнительные ресурсы:
- [docker-compose elasticsearch + kibana](https://github.com/IvanChet-4/DevOps_ext/blob/main/Module_10/L_3/docker/docker-compose.yml);
- [поднимаем elk в docker](https://www.elastic.co/guide/en/elasticsearch/reference/7.17/docker.html);
- [поднимаем elk в docker с filebeat и docker-логами](https://www.sarulabs.com/post/5/2019-08-12/sending-docker-logs-to-elasticsearch-and-kibana-with-filebeat.html);
- [конфигурируем logstash](https://www.elastic.co/guide/en/logstash/7.17/configuration.html);
- [плагины filter для logstash](https://www.elastic.co/guide/en/logstash/current/filter-plugins.html);
- [конфигурируем filebeat](https://www.elastic.co/guide/en/beats/libbeat/5.3/config-file-format.html);
- [привязываем индексы из elastic в kibana](https://www.elastic.co/guide/en/kibana/7.17/index-patterns.html);
- [как просматривать логи в kibana](https://www.elastic.co/guide/en/kibana/current/discover.html);
- [решение ошибки increase vm.max_map_count elasticsearch](https://stackoverflow.com/questions/42889241/how-to-increase-vm-max-map-count).

**Примечание**: если у вас недоступны официальные образы, можете найти альтернативные варианты в DockerHub, например, [такой](https://hub.docker.com/layers/bitnami/elasticsearch/7.17.13/images/sha256-8084adf6fa1cf24368337d7f62292081db721f4f05dcb01561a7c7e66806cc41?context=explore).

### Задание 1. Elasticsearch 

Установите и запустите Elasticsearch, после чего поменяйте параметр cluster_name на случайный. 

*Приведите скриншот команды 'curl -X GET 'localhost:9200/_cluster/health?pretty', сделанной на сервере с установленным Elasticsearch. Где будет виден нестандартный cluster_name*.

#### Решение:  

Перед запуском выполняем:  

```  
sudo sysctl -w vm.max_map_count=262144
```  

Добавляем в docker-compose.yml параметр:  

```  
- cluster.name=netology-custom-cluster
```  

Добавляем файл filebeat.yml:  

[filebeat.yml](https://github.com/IvanChet-4/DevOps_ext/blob/main/Module_10/L_3/config/filebeat.yml)  

Запускаем:  

```  
docker compose up -d
```  

<img width="1513" height="273" alt="image" src="https://github.com/user-attachments/assets/f5eaacde-0e2d-4dbb-a53c-bb2108f7bdbe" />  

<img width="1509" height="202" alt="image" src="https://github.com/user-attachments/assets/d6ef36d9-707b-449f-8fa2-c36905e07315" />  

Теперь выполняем команду:  

```  
curl -X GET 'localhost:9200/_cluster/health?pretty
```  

Видим корректно установленное имя кластера (netology-custom-cluster):  

<img width="796" height="424" alt="image" src="https://github.com/user-attachments/assets/4069578f-95ce-4d58-ab7a-3ee96fa5d411" />  


---

### Задание 2. Kibana

Установите и запустите Kibana.

*Приведите скриншот интерфейса Kibana на странице http://<ip вашего сервера>:5601/app/dev_tools#/console, где будет выполнен запрос GET /_cluster/health?pretty*.  

#### Решение:    

Открываем веб-интерфейс http://localhost:5601/app/dev_tools#/console:  

<img width="1030" height="599" alt="image" src="https://github.com/user-attachments/assets/0f7a55d0-04ad-4a22-8860-c81f64e2b068" />  


Выполняем запрос  GET /_cluster/health?pretty :  

<img width="1164" height="652" alt="image" src="https://github.com/user-attachments/assets/d7663306-667a-447c-82b6-2d69ab3829ce" />  

---

### Задание 3. Logstash

Установите и запустите Logstash и Nginx. С помощью Logstash отправьте access-лог Nginx в Elasticsearch. 

*Приведите скриншот интерфейса Kibana, на котором видны логи Nginx.*

#### Решение:    

Добавляем конфигурационный файл logstash.conf:  

[logstash.conf](https://github.com/IvanChet-4/DevOps_ext/blob/main/Module_10/L_3/config/logstash.conf)  

Добавляем дополнительные сервисы (nginx, logstash) в docker-compose.yml:  

[docker-compose.yml](https://github.com/IvanChet-4/DevOps_ext/blob/main/Module_10/L_3/docker/docker-compose.yml)  

```
Смотрим индексы
curl -X GET "localhost:9200/_cat/indices?v"
```

---

### Задание 4. Filebeat. 

Установите и запустите Filebeat. Переключите поставку логов Nginx с Logstash на Filebeat. 

*Приведите скриншот интерфейса Kibana, на котором видны логи Nginx, которые были отправлены через Filebeat.*

#### Решение  


## Дополнительные задания (со звёздочкой*)
Эти задания дополнительные, то есть не обязательные к выполнению, и никак не повлияют на получение вами зачёта по этому домашнему заданию. Вы можете их выполнить, если хотите глубже шире разобраться в материале.

### Задание 5*. Доставка данных 

Настройте поставку лога в Elasticsearch через Logstash и Filebeat любого другого сервиса , но не Nginx. 
Для этого лог должен писаться на файловую систему, Logstash должен корректно его распарсить и разложить на поля. 

*Приведите скриншот интерфейса Kibana, на котором будет виден этот лог и напишите лог какого приложения отправляется.*

#### Решение  
