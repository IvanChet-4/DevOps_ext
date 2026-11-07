# Домашнее задание к занятию 5. «Практическое применение Docker»

### Инструкция к выполнению

1. Для выполнения заданий обязательно ознакомьтесь с [инструкцией](https://github.com/netology-code/devops-materials/blob/master/cloudwork.MD) по экономии облачных ресурсов. Это нужно, чтобы не расходовать средства, полученные в результате использования промокода.
3. **Своё решение к задачам оформите в вашем GitHub репозитории.**
4. В личном кабинете отправьте на проверку ссылку на .md-файл в вашем репозитории.
5. Сопроводите ответ необходимыми скриншотами.

---
## Примечание: Ознакомьтесь со схемой виртуального стенда [по ссылке](https://github.com/netology-code/shvirtd-example-python/blob/main/schema.pdf)

---

## Задача 0
1. Убедитесь что у вас НЕ(!) установлен ```docker-compose```, для этого получите следующую ошибку от команды ```docker-compose --version```
```
Command 'docker-compose' not found, but can be installed with:

sudo snap install docker          # version 24.0.5, or
sudo apt  install docker-compose  # version 1.25.0-1

See 'snap info docker' for additional versions.
```
В случае наличия установленного в системе ```docker-compose``` - удалите его.  
2. Убедитесь что у вас УСТАНОВЛЕН ```docker compose```(без тире) версии не менее v2.24.X, для это выполните команду ```docker compose version```  
###  **Своё решение к задачам оформите в вашем GitHub репозитории!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!**

## Решение

Установил:

<img width="464" height="46" alt="image" src="https://github.com/user-attachments/assets/cc07631f-c828-4f4d-8d90-b1d6151289c3" />

---

## Задача 1
1. Сделайте в своем GitHub пространстве fork [репозитория](https://github.com/netology-code/shvirtd-example-python).

2. Создайте файл ```Dockerfile.python``` на основе существующего `Dockerfile`:
   - Используйте базовый образ ```python:3.12-slim```
   - Обязательно используйте конструкцию ```COPY . .``` в Dockerfile
   - Создайте `.dockerignore` файл для исключения ненужных файлов
   - Используйте ```CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "5000"]``` для запуска
   - Протестируйте корректность сборки
2.1 Используйте multistage сборку вместо single stage.
3. (Необязательная часть, *) Изучите инструкцию в проекте и запустите web-приложение без использования docker, с помощью venv. (Mysql БД можно запустить в docker run).
4. (Необязательная часть, *) Изучите код приложения и добавьте управление названием таблицы через ENV переменную.

## Решение

1. Сделал форк:  

<img width="958" height="272" alt="image" src="https://github.com/user-attachments/assets/6119df22-90af-4530-add1-253e208b2992" />

2. Создал файлы:  
[Dockerfile.python](https://github.com/IvanChet-4/DevOps_ext/blob/main/Module_15/L2/Dockerfile.python)  
[.dockerignore](https://github.com/IvanChet-4/DevOps_ext/blob/main/Module_15/L2/.dockerignore)  

 
3. Сборка:  

```docker build -f Dockerfile.python -t my-python-app:latest .```  

Тест корректности сборки:  

```docker run -p 5000:5000 my-python-app:latest```  

<img width="1866" height="688" alt="image" src="https://github.com/user-attachments/assets/93636c3f-7683-4421-bdd9-a44ddec7d67f" />

<img width="1849" height="126" alt="image" src="https://github.com/user-attachments/assets/f4260bb5-eaad-43df-9b2d-d46abb42a798" />

Запуск БД Mysql в docker run:  

```
docker run --name mysql-db -e MYSQL_ROOT_PASSWORD=secret_pass -e MYSQL_DATABASE=app_db -p 3306:3306 -d mysql:8.0
```

Запуск web-приложения без использования docker, с помощью venv:  

```
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
export DB_HOST="127.0.0.1"
export TABLE_NAME="custom_users_table" 
uvicorn main:app --host 0.0.0.0 --port 5000
```

<img width="1083" height="181" alt="image" src="https://github.com/user-attachments/assets/2cfa9d43-4fbc-4c10-9a71-18a612d0a45c" />

4. Исправил main.py в репозитории назвал [main_table.py](https://github.com/IvanChet-4/DevOps_ext/blob/main/Module_15/L2/main_table.py) :   

```
docker run -p 5000:5000 -e TABLE_NAME="user_logs" my-python-app:latest
```

<img width="966" height="119" alt="image" src="https://github.com/user-attachments/assets/be518644-e95e-4a7e-b7fe-034abe7b4c01" />


---
### ВНИМАНИЕ!
!!! В процессе последующего выполнения ДЗ НЕ изменяйте содержимое файлов в fork-репозитории! Ваша задача ДОБАВИТЬ 5 файлов: ```Dockerfile.python```, ```compose.yaml```, ```.gitignore```, ```.dockerignore```,```bash-скрипт```. Если вам понадобилось внести иные изменения в проект - вы что-то делаете неверно!
---

## Задача 2 (*)
1. Создайте в yandex cloud container registry с именем "test" с помощью "yc tool" . [Инструкция](https://cloud.yandex.ru/ru/docs/container-registry/quickstart/?from=int-console-help)
2. Настройте аутентификацию вашего локального docker в yandex container registry.
3. Соберите и залейте в него образ с python приложением из задания №1.
4. Просканируйте образ на уязвимости.
5. В качестве ответа приложите отчет сканирования.

## Задача 3
1. Изучите файл "proxy.yaml"
2. Создайте в репозитории с проектом файл ```compose.yaml```. С помощью директивы "include" подключите к нему файл "proxy.yaml".
3. Опишите в файле ```compose.yaml``` следующие сервисы: 

- ```web```. Образ приложения должен ИЛИ собираться при запуске compose из файла ```Dockerfile.python``` ИЛИ скачиваться из yandex cloud container registry(из задание №2 со *). Контейнер должен работать в bridge-сети с названием ```backend``` и иметь фиксированный ipv4-адрес ```172.20.0.5```. Сервис должен всегда перезапускаться в случае ошибок.
Передайте необходимые ENV-переменные для подключения к Mysql базе данных по сетевому имени сервиса ```web``` 

- ```db```. image=mysql:8. Контейнер должен работать в bridge-сети с названием ```backend``` и иметь фиксированный ipv4-адрес ```172.20.0.10```. Явно перезапуск сервиса в случае ошибок. Передайте необходимые ENV-переменные для создания: пароля root пользователя, создания базы данных, пользователя и пароля для web-приложения.Обязательно используйте уже существующий .env file для назначения секретных ENV-переменных!

4. Запустите проект локально с помощью docker compose , добейтесь его стабильной работы: команда ```curl -L http://127.0.0.1:8090``` должна возвращать в качестве ответа время и локальный IP-адрес. Если сервисы не стартуют воспользуйтесь командами: ```docker ps -a ``` и ```docker logs <container_name>``` . Если вместо IP-адреса вы получаете информационную ошибку --убедитесь, что вы шлете запрос на порт ```8090```, а не 5000.

5. Подключитесь к БД mysql с помощью команды ```docker exec -ti <имя_контейнера> mysql -uroot -p<пароль root-пользователя>```(обратите внимание что между ключем -u и логином root нет пробела. это важно!!! тоже самое с паролем) . Введите последовательно команды (не забываем в конце символ ; ): ```show databases; use <имя вашей базы данных(по-умолчанию virtd, как это указано в .env)>; show tables; SELECT * from requests LIMIT 10;```. Примечание: таблица в БД создается после первого поступившего запроса к приложению.

6. Остановите проект. В качестве ответа приложите скриншот sql-запроса.

## Решение

1-3. Создал файл [compose.yaml](https://github.com/IvanChet-4/DevOps_ext/blob/main/Module_15/L2/compose.yaml)

4. Запустил команду ```curl -L http://127.0.0.1:8090```

<img width="995" height="181" alt="image" src="https://github.com/user-attachments/assets/acea22fa-ea1f-4f74-9ffa-9f8f498f91e5" />

5.

<img width="877" height="598" alt="image" src="https://github.com/user-attachments/assets/37ea81a4-d7a3-4b26-8aa2-7e8e6ff07b1a" />

<img width="691" height="272" alt="image" src="https://github.com/user-attachments/assets/5cf0a417-aa4e-40d4-a9ba-00ebcda23229" />

<img width="444" height="363" alt="image" src="https://github.com/user-attachments/assets/4abc4d87-ffc7-4c3b-a61e-4a01465dcbcc" />

6.

<img width="1479" height="185" alt="image" src="https://github.com/user-attachments/assets/0734a390-c249-42e1-84a1-bb15d81c3a88" />


## Задача 4
1. Запустите в Yandex Cloud ВМ (вам хватит 2 Гб Ram).
2. Подключитесь к Вм по ssh и установите docker.
3. Напишите bash-скрипт, который скачает ваш fork-репозиторий в каталог /opt и запустит проект целиком.
4. Зайдите на сайт проверки http подключений, например(или аналогичный): ```https://check-host.net/check-http``` и запустите проверку вашего сервиса ```http://<внешний_IP-адрес_вашей_ВМ>:8090```. Таким образом трафик будет направлен в ingress-proxy. Трафик должен пройти через цепочки: Пользователь → Internet → Nginx → HAProxy → FastAPI(запись в БД) → HAProxy → Nginx → Internet → Пользователь
5. (Необязательная часть) Дополнительно настройте remote ssh context к вашему серверу. Отобразите список контекстов и результат удаленного выполнения ```docker ps -a```
6. Повторите SQL-запрос на сервере и приложите скриншот и ссылку на fork.

## Решение

<img width="654" height="128" alt="image" src="https://github.com/user-attachments/assets/1847485b-1de6-49c4-8efb-f4fe35ff0902" />

<img width="1415" height="483" alt="image" src="https://github.com/user-attachments/assets/0631c564-5152-4c09-b58e-1bc9176600d2" />

<img width="609" height="134" alt="image" src="https://github.com/user-attachments/assets/3de38831-241d-456d-9f99-e091b02f7a42" />

<img width="1703" height="316" alt="image" src="https://github.com/user-attachments/assets/8318cfb7-6c63-4b10-b7e4-6fda9a2f8377" />

<img width="813" height="225" alt="image" src="https://github.com/user-attachments/assets/dc60473e-9d12-4509-b6f2-807c5eb1f339" />

<img width="1402" height="874" alt="image" src="https://github.com/user-attachments/assets/143f26ed-f52b-4fc5-9c17-5e133e002570" />

<img width="1291" height="161" alt="image" src="https://github.com/user-attachments/assets/b320b346-dd0d-4cc6-a2a7-d4628ceafd7a" />

<img width="1026" height="682" alt="image" src="https://github.com/user-attachments/assets/d448d5fb-bacd-4a42-909b-b3984027be58" />

<img width="744" height="854" alt="image" src="https://github.com/user-attachments/assets/8caed9fb-7e64-42dc-be3e-bc394cd54135" />

Скрипт [test.sh](https://github.com/IvanChet-4/DevOps_ext/blob/main/Module_15/L2/test.sh)

```
docker context create yc-vm --docker "host=ssh://ubuntu@51.250.86.18"
docker context ls
```

## Задача 5 (*)
1. Напишите и задеплойте на вашу облачную ВМ bash скрипт, который произведет резервное копирование БД mysql в директорию "/opt/backup" с помощью запуска в сети "backend" контейнера из образа ```schnitzler/mysqldump``` при помощи ```docker run ...``` команды. Подсказка: "документация образа."
2. Протестируйте ручной запуск
3. Настройте выполнение скрипта раз в 1 минуту через cron, crontab или systemctl timer. Придумайте способ не светить логин/пароль в git!!
4. Предоставьте скрипт, cron-task и скриншот с несколькими резервными копиями в "/opt/backup"

## Задача 6
Скачайте docker образ ```hashicorp/terraform:latest``` и скопируйте бинарный файл ```/bin/terraform``` на свою локальную машину, используя dive и docker save.
Предоставьте скриншоты  действий .

<img width="1811" height="904" alt="image" src="https://github.com/user-attachments/assets/176113b5-c178-41c3-bf92-997f455dfb3a" />

<img width="639" height="86" alt="image" src="https://github.com/user-attachments/assets/8c06b434-6e3f-4622-b814-012f7e07a673" />

```
docker pull hashicorp/terraform:latest
dive hashicorp/terraform:latest
docker run --rm -it \
  -v /var/run/docker.sock:/var/run/docker.sock \
  wagoodman/dive:latest hashicorp/terraform:latest

docker save hashicorp/terraform:latest | gzip > tf_image.tar.gz
tar -ztf tf_image.tar.gz | grep layer.tar
mkdir tf_extract && tar -zxf tf_image.tar.gz -C tf_extract
cd tf_extract

find . -type f -exec sh -c 'tar -tf "$1" 2>/dev/null | grep -q "terraform"' _ {} \; -print
./blobs/sha256/b31c7f8fb200e48c18f2f1f189def5cd5d972a673186cf3bee026ac9071c2d80
./blobs/sha256/2d664eecf5e7d017570e58c8cec8a8a65adff55b713f5f370bfddd22a0698cb6

tar -xf ./blobs/sha256/b31c7f8fb200e48c18f2f1f189def5cd5d972a673186cf3bee026ac9071c2d80 bin/terraform 2>/dev/null || tar -xf ./blobs/sha256/b31c7f8fb200e48c18f2f1f189def5cd5d972a673186cf3bee026ac9071c2d80 terraform 2>/dev/null
tar -xf ./blobs/sha256/2d664eecf5e7d017570e58c8cec8a8a65adff55b713f5f370bfddd22a0698cb6 bin/terraform 2>/dev/null || tar -xf ./blobs/sha256/2d664eecf5e7d017570e58c8cec8a8a65adff55b713f5f370bfddd22a0698cb6 terraform 2>/dev/null

cd bin/
./terraform version
```
