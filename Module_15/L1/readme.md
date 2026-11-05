# Домашнее задание к занятию 4 «Оркестрация группой Docker контейнеров на примере Docker Compose»

### Инструкция к выполению

1. Для выполнения заданий обязательно ознакомьтесь с [инструкцией](https://github.com/netology-code/devops-materials/blob/master/cloudwork.MD) по экономии облачных ресурсов. Это нужно, чтобы не расходовать средства, полученные в результате использования промокода.
2. Практические задачи выполняйте на личной рабочей станции или созданной вами ранее ВМ в облаке.
3. Своё решение к задачам оформите в вашем GitHub репозитории в формате markdown!!!
4. В личном кабинете отправьте на проверку ссылку на .md-файл в вашем репозитории.

## Задача 1

Сценарий выполнения задачи:
- Установите docker и docker compose plugin на свою linux рабочую станцию или ВМ.
- Если dockerhub недоступен создайте файл /etc/docker/daemon.json с содержимым: ```{"registry-mirrors": ["https://mirror.gcr.io", "https://daocloud.io", "https://c.163.com/", "https://registry.docker-cn.com"]}```
- Зарегистрируйтесь и создайте публичный репозиторий  с именем "custom-nginx" на https://hub.docker.com (ТОЛЬКО ЕСЛИ У ВАС ЕСТЬ ДОСТУП);
- скачайте образ nginx:1.29.0;
- Создайте Dockerfile и реализуйте в нем замену дефолтной индекс-страницы(/usr/share/nginx/html/index.html), на файл index.html с содержимым:
```
<html>
<head>
Hey, Netology
</head>
<body>
<h1>I will be DevOps Engineer!</h1>
</body>
</html>
```
- Соберите и отправьте созданный образ в свой dockerhub-репозитории c tag 1.0.0 (ТОЛЬКО ЕСЛИ ЕСТЬ ДОСТУП). 
- Предоставьте ответ в виде ссылки на https://hub.docker.com/<username_repo>/custom-nginx/general .

## Решение  

Установил docker и docker compose plugin на ВМ.  

Зарегистрировался в докер хаб и создал репозиторий <br>
<b> https://hub.docker.com/repository/docker/4ivan/custom-nginx </b> <br>
Создал [Dockerfile](https://github.com/IvanChet-4/DevOps_ext/blob/main/Module_15/L1/Dockerfile)  
Запустил сборку образа с помощью команды docker build   

Присвоил полученному образу тег через docker tag и отправил его в свой репозиторий с помощью docker push  
<b> https://hub.docker.com/repository/docker/4ivan/custom-nginx/general </b><br>
Теперь скачать мой образ можно при помощи команды:<br>

```
docker pull 4ivan/custom-nginx
```

## Задача 2
1. Запустите ваш образ custom-nginx:1.0.0 командой docker run в соответвии с требованиями:
- имя контейнера "ФИО-custom-nginx-t2"
- контейнер работает в фоне
- контейнер опубликован на порту хост системы 127.0.0.1:8080
2. Не удаляя, переименуйте контейнер в "custom-nginx-t2"
3. Выполните команду ```date +"%d-%m-%Y %T.%N %Z" ; sleep 0.150 ; docker ps ; ss -tlpn | grep 127.0.0.1:8080  ; docker logs custom-nginx-t2 -n1 ; docker exec -it custom-nginx-t2 base64 /usr/share/nginx/html/index.html```
4. Убедитесь с помощью curl или веб браузера, что индекс-страница доступна.

В качестве ответа приложите скриншоты консоли, где видно все введенные команды и их вывод.

## Решение

<br>
Для запуска контейнера: <br> 

```
docker run --name ichetverkin-custom-nginx-t2 -p 127.0.0.1:8080:80 -e TERM=xterm -d custom-nginx-t2
```

![Запуск контейнера](https://github.com/IvanChet-4/Dev/blob/main/images/Homework%201-3/%D0%97%D0%B0%D0%BF%D1%83%D1%81%D0%BA%20%D0%BA%D0%BE%D0%BD%D1%82%D0%B5%D0%B9%D0%BD%D0%B5%D1%80%D0%B0.png)

<br>
Команда для переименования контейнера:<br> 

```
docker rename ichetverkin-custom-nginx-t2 custom-nginx-t2
```

<br>
<br>
Выполнил команды:<br>

```
date +"%d-%m-%Y %T.%N %Z" ; sleep 0.150 ; docker ps ; ss -tlpn | grep 127.0.0.1:8080 ; docker logs custom-nginx-t2 -n1 ; docker exec -it custom-nginx-t2 base64 /usr/share/nginx/html/index.html
```

<br>

```
сurl 127.0.0.1:8080

<html>
<head> Hey, Netology</head>
<body>
 <h1>I will be DevOps Engineer !</h1>
</body>
</html>
```

 <br>
 <br>
 
![Результат в браузере](https://github.com/IvanChet-4/Dev/blob/main/images/Homework%201-3/%D0%A0%D0%B5%D0%B7%D1%83%D0%BB%D1%8C%D1%82%D0%B0%D1%82%20%D0%B2%20%D0%B1%D1%80%D0%B0%D1%83%D0%B7%D0%B5%D1%80%D0%B5.png)

<br>

## Задача 3
1. Воспользуйтесь docker help или google, чтобы узнать как подключиться к стандартному потоку ввода/вывода/ошибок контейнера "custom-nginx-t2".
2. Подключитесь к контейнеру и нажмите комбинацию Ctrl-C.
3. Выполните ```docker ps -a``` и объясните своими словами почему контейнер остановился.
4. Перезапустите контейнер
5. Зайдите в интерактивный терминал контейнера "custom-nginx-t2" с оболочкой bash.
6. Установите любимый текстовый редактор(vim, nano итд) с помощью apt-get.
7. Отредактируйте файл "/etc/nginx/conf.d/default.conf", заменив порт "listen 80" на "listen 81".
8. Запомните(!) и выполните команду ```nginx -s reload```, а затем внутри контейнера ```curl http://127.0.0.1:80 ; curl http://127.0.0.1:81```.
9. Выйдите из контейнера, набрав в консоли  ```exit``` или Ctrl-D.
10. Проверьте вывод команд: ```ss -tlpn | grep 127.0.0.1:8080``` , ```docker port custom-nginx-t2```, ```curl http://127.0.0.1:8080```. Кратко объясните суть возникшей проблемы.
11. * Это дополнительное, необязательное задание. Попробуйте самостоятельно исправить конфигурацию контейнера, используя доступные источники в интернете. Не изменяйте конфигурацию nginx и не удаляйте контейнер. Останавливать контейнер можно. [пример источника](https://www.baeldung.com/linux/assign-port-docker-container)
12. Удалите запущенный контейнер "custom-nginx-t2", не останавливая его.(воспользуйтесь --help или google)

В качестве ответа приложите скриншоты консоли, где видно все введенные команды и их вывод.

## Решение

<br>
Для подключения к к стандартному потоку ввода/вывода/ошибок контейнера необходимо использовать команду: <br>

```
docker attach ichetverkin-custom-nginx-t2
```

<br>
Прожал как по заданию:<br>

```
ctrl + c
docker ps -a
```

Решил проверить описание ключа, который присутствует в последней команде.<br>
Описание любой команды можно найти используя man или --help: <br>

```
docker ps --help     
```
  
- выводит следующее:    -a, --all             Show all containers (default shows just running)<br>

Соответственно команда "docker ps -a" никак не повлияла на остановку контейнера т.е. контейнер остановлися после введения команды ctrl + c, а команда "docker ps -a" вывела информацию и о запущенных контейнерах и об образах<br>
<br>
Контейер остановился после применения команды ctrl + c т.к. получил сигнал на уничтожение SIGINT forcefully exiting <br>
Запустил контейнер: <br>

```
docker start 06dbac9c3ad7
```

<br>
Чтобы контейнер не останавливался нужно отключить перенаправление сигналов, пример команды:<br>

```
docker attach --sig-proxy=false ichetverkin-custom-nginx-t2
```

Для отключения от потоков контейнера необходимо три раза ввести: ctrl + c<br>
<br>
Подключаемся к контейнеру для установки текстовых редакторов и изменения порта nginx: <br>

```
docker exec -it 06dbac9c3ad7 /bin/bash
apt update
apt install nano vim
```

<br>
Заменил значение порта в конфиг файле nginx с 80 на 81<br>
Проверил вывод команды curl внутри контейнера:<br>

```
root@06dbac9c3ad7:/# curl http://127.0.0.1:80
curl: (7) Failed to connect to 127.0.0.1 port 80 after 0 ms: Connection refused
root@06dbac9c3ad7:/#  curl http://127.0.0.1:81
<html>
<head> Hey, Netology</head>
<body>
 <h1>I will be DevOps Engineer !</h1>
</body>
</html>
```

<br>
Очевидно, что проблема связана с параметрами заданными при старте контейнера, порт 80 остался в настройках контейнера <br>
docker ps<br>

```
CONTAINER ID   IMAGE             COMMAND                  CREATED          STATUS         PORTS                                     NAMES
06dbac9c3ad7   custom-nginx-t2   "/docker-entrypoint.…"   48 minutes ago   Up 3 minutes   0.0.0.0:8080->80/tcp, [::]:8080->80/tcp   ichetverkin-custom-nginx-t2
```

<br>
Нам нужно поменять порт в конфиг файлах контейнера. <br>
Для этого выполняем остановку контейнера и сервиса докер: <br>

```
docker stop 06dbac9c3ad7
systemctl stop docker
```
Заходим в директорию:<br>

```
/var/lib/docker/containers/<ID>/
```

<b>config.v2.json</b> тут редактируем параметры "PortBindings"<br>
<b>hostconfig.json</b> тут редактируем параметры "ExposedPorts"<br>
<br>
После внесенных изменений запускаем докер, стартуем наш контейнер и делаем docker ps<br>
 
```
CONTAINER ID   IMAGE             COMMAND                  CREATED             STATUS         PORTS                                     NAMES
06dbac9c3ad7   custom-nginx-t2   "/docker-entrypoint.…"   About an hour ago   Up 3 seconds   0.0.0.0:8080->81/tcp, [::]:8080->81/tcp   ichetverkin-custom-nginx-t2
```

Страница и в браузере и по curl снова отображается.<br>
<br>
Для удаления запущенного контенейра:<br>
 
```
docker rm -f $(docker ps -a -q)
```

<br>
<br>

## Задача 4


- Запустите первый контейнер из образа ***centos*** c любым тегом в фоновом режиме, подключив папку  текущий рабочий каталог ```$(pwd)``` на хостовой машине в ```/data``` контейнера, используя ключ -v.
- Запустите второй контейнер из образа ***debian*** в фоновом режиме, подключив текущий рабочий каталог ```$(pwd)``` в ```/data``` контейнера. 
- Подключитесь к первому контейнеру с помощью ```docker exec``` и создайте текстовый файл любого содержания в ```/data```.
- Добавьте ещё один файл в текущий каталог ```$(pwd)``` на хостовой машине.
- Подключитесь во второй контейнер и отобразите листинг и содержание файлов в ```/data``` контейнера.


В качестве ответа приложите скриншоты консоли, где видно все введенные команды и их вывод.


## Решение

<br>

Скачал образы с докерхаб и создал директорию на хостовой машине<br>

```
docker pull centos
docker pull debian
mkdir /home/user7/Z4
```

Создал директорию с большой буквы и столкнулся с ошибкой при запуске:<br>

```
docker run -t -i -v /home/user7/Z4:/data  centos /bin/bash
docker: invalid reference format: repository name (/home/user7/Z4) must be lowercase.
```

Попробовал запустить контейнеры без указания порт маппинга, доступ в интернет отсутсвовал.<br>
Итоговые команды запуска centos и debian (с доступом в интернет):<br>

```
docker run --name centos-container -e TERM=xterm -d -t -v /home/user7/z4:/data centos /bin/bash
docker run --name debian-container -e TERM=xterm -d -t -v /home/user7/z4:/data debian /bin/bash
```

![Доступ в интернет из контейнеров](https://github.com/IvanChet-4/Dev/blob/main/images/Homework%201-3/%D0%94%D0%BE%D1%81%D1%82%D1%83%D0%BF%20%D0%B2%20%D0%B8%D0%BD%D1%82%D0%B5%D1%80%D0%BD%D0%B5%D1%82%20%D0%B8%D0%B7%20%D0%BA%D0%BE%D0%BD%D1%82%D0%B5%D0%B9%D0%BD%D0%B5%D1%80%D0%BE%D0%B2.png)

Создал на хостовой машине файл - файл виден и из контейнеров.<br>

![Создал файл на хосте](https://github.com/IvanChet-4/Dev/blob/main/images/Homework%201-3/%D0%A1%D0%BE%D0%B7%D0%B4%D0%B0%D0%BB%20%D1%84%D0%B0%D0%B9%D0%BB%20%D0%BD%D0%B0%20%D1%85%D0%BE%D1%81%D1%82%D0%B5.png)

Подключился к первому контейнеру и создал файл - файл также виден и из контейнеров и с хостовой машины.<br>

![Создал файл из контейнера и проверил его видимость](https://github.com/IvanChet-4/Dev/blob/main/images/Homework%201-3/%D0%A1%D0%BE%D0%B7%D0%B4%D0%B0%D0%BB%20%D1%84%D0%B0%D0%B9%D0%BB%20%D0%B8%D0%B7%20%D0%BA%D0%BE%D0%BD%D1%82%D0%B5%D0%B9%D0%BD%D0%B5%D1%80%D0%B0%20%D0%B8%20%D0%BF%D1%80%D0%BE%D0%B2%D0%B5%D1%80%D0%B8%D0%BB%20%D0%B5%D0%B3%D0%BE%20%D0%B2%D0%B8%D0%B4%D0%B8%D0%BC%D0%BE%D1%81%D1%82%D1%8C.png)

Проверил на хостовой машине, с какими правами отображается созданный файл из контейнера. <br>

![Права на файл созданный из контейнера](https://github.com/IvanChet-4/Dev/blob/main/images/Homework%201-3/%D0%9F%D1%80%D0%B0%D0%B2%D0%B0%20%D0%BD%D0%B0%20%D1%84%D0%B0%D0%B9%D0%BB%20%D1%81%D0%BE%D0%B7%D0%B4%D0%B0%D0%BD%D0%BD%D1%8B%D0%B9%20%D0%B8%D0%B7%20%D0%BA%D0%BE%D0%BD%D1%82%D0%B5%D0%B9%D0%BD%D0%B5%D1%80%D0%B0.png)


<br>
<br>

## Задача 5

1. Создайте отдельную директорию(например /tmp/netology/docker/task5) и 2 файла внутри него.
"compose.yaml" с содержимым:
```
version: "3"
services:
  portainer:
    network_mode: host
    image: portainer/portainer-ce:latest
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
```
"docker-compose.yaml" с содержимым:
```
version: "3"
services:
  registry:
    image: registry:2

    ports:
    - "5000:5000"
```

И выполните команду "docker compose up -d". Какой из файлов был запущен и почему? (подсказка: https://docs.docker.com/compose/compose-application-model/#the-compose-file )

2. Отредактируйте файл compose.yaml так, чтобы были запущенны оба файла. (подсказка: https://docs.docker.com/compose/compose-file/14-include/)

3. Выполните в консоли вашей хостовой ОС необходимые команды чтобы залить образ custom-nginx как custom-nginx:latest в запущенное вами, локальное registry. Дополнительная документация: https://distribution.github.io/distribution/about/deploying/
4. Откройте страницу "https://127.0.0.1:9000" и произведите начальную настройку portainer.(логин и пароль адмнистратора)
5. Откройте страницу "http://127.0.0.1:9000/#!/home", выберите ваше local  окружение. Перейдите на вкладку "stacks" и в "web editor" задеплойте следующий компоуз:

```
version: '3'

services:
  nginx:
    image: 127.0.0.1:5000/custom-nginx
    ports:
      - "9090:80"
```
6. Перейдите на страницу "http://127.0.0.1:9000/#!/2/docker/containers", выберите контейнер с nginx и нажмите на кнопку "inspect". В представлении <> Tree разверните поле "Config" и сделайте скриншот от поля "AppArmorProfile" до "Driver".

7. Удалите любой из манифестов компоуза(например compose.yaml).  Выполните команду "docker compose up -d". Прочитайте warning, объясните суть предупреждения и выполните предложенное действие. Погасите compose-проект ОДНОЙ(обязательно!!) командой.

В качестве ответа приложите скриншоты консоли, где видно все введенные команды и их вывод, файл compose.yaml , скриншот portainer c задеплоенным компоузом.

## Решение

<br>

Создаем директории и файлы по заданию. Список команд: <br>

```
user7@user7-MS-7D13:~$ mkdir netology
user7@user7-MS-7D13:~$ mkdir ./netology/docker
user7@user7-MS-7D13:~$ mkdir ./netology/docker/task5
user7@user7-MS-7D13:~$ cd ./netology/docker/task5
user7@user7-MS-7D13:~/netology/docker/task5$ nano compose.yaml
user7@user7-MS-7D13:~/netology/docker/task5$ vi docker-compose.yaml
```

Запустили команду: <br>

```
docker compose up -d
```

Будет запущен файл compose.yaml по приоритету.   

![Запуск команды](https://github.com/IvanChet-4/Dev/blob/main/images/Homework%201-3/%D0%97%D0%B0%D0%BF%D1%83%D1%81%D0%BA%20%D0%BA%D0%BE%D0%BC%D0%B0%D0%BD%D0%B4%D1%8B.png)

Получили предупреждение WARN[0000]:<br>

```
/home/user7/netology/docker/task5/compose.yaml: the attribute `version` is obsolete, it will be ignored, please remove it to avoid potential confusion 
``` 

Указание версии является избыточным и может привести к появлению предупреждений т.к. Docker Compose по умолчанию использует последнюю спецификацию Compose.<br>
<br>
Изменили compose.yaml согласно рекомендации в предупреждении и подсказки в задании:<br>

```
include:
  - path: ./docker-compose.yaml
services:
  portainer:
    network_mode: host
    image: portainer/portainer-ce:latest
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
```

![Запуск двух контейнеров после исправления конфига](https://github.com/IvanChet-4/Dev/blob/main/images/Homework%201-3/%D0%97%D0%B0%D0%BF%D1%83%D1%81%D0%BA%20%D0%B4%D0%B2%D1%83%D1%85%20%D0%BA%D0%BE%D0%BD%D1%82%D0%B5%D0%B9%D0%BD%D0%B5%D1%80%D0%BE%D0%B2%20%D0%BF%D0%BE%D1%81%D0%BB%D0%B5%20%D0%B8%D1%81%D0%BF%D1%80%D0%B0%D0%B2%D0%BB%D0%B5%D0%BD%D0%B8%D1%8F%20%D0%BA%D0%BE%D0%BD%D1%84%D0%B8%D0%B3%D0%B0.png)

Для создания локального registry ставим необходимый пакет:<br>

```
apt install docker-registry
```
Выполняем команды:<br>

```
docker compose up -d
```

![Локальный registry](https://github.com/IvanChet-4/Dev/blob/main/images/Homework%201-3/%D0%9B%D0%BE%D0%BA%D0%B0%D0%BB%D1%8C%D0%BD%D1%8B%D0%B9%20registry.png)


Открыл страницу https://127.0.0.1:9000 и создал нового пользователя.<br>

![Создал учетную запись](https://github.com/IvanChet-4/Dev/blob/main/images/Homework%201-3/%D0%A1%D0%BE%D0%B7%D0%B4%D0%B0%D0%BB%20%D1%83%D1%87%D0%B5%D1%82%D0%BD%D1%83%D1%8E%20%D0%B7%D0%B0%D0%BF%D0%B8%D1%81%D1%8C.png)

Перешел на страницу http://127.0.0.1:9000/#!/home<br>

![Стэк лист](https://github.com/IvanChet-4/Dev/blob/main/images/Homework%201-3/%D0%A1%D1%82%D1%8D%D0%BA%20%D0%BB%D0%B8%D1%81%D1%82.png)


![Веб эдитор](https://github.com/IvanChet-4/Dev/blob/main/images/Homework%201-3/%D0%92%D0%B5%D0%B1%20%D1%8D%D0%B4%D0%B8%D1%82%D0%BE%D1%80.png)

Добавили в веб эдитор следующий компоуз:<br>

```
version: '3'

services:
  nginx:
    image: 127.0.0.1:5000/custom-nginx
    ports:
      - "9090:80"
```

Прожали деплой.<br>

Посмотрели список контейнеров:<br>

![Список контейнеров](https://github.com/IvanChet-4/Dev/blob/main/images/Homework%201-3/%D0%A1%D0%BF%D0%B8%D1%81%D0%BE%D0%BA%20%D0%BA%D0%BE%D0%BD%D1%82%D0%B5%D0%B9%D0%BD%D0%B5%D1%80%D0%BE%D0%B2.png)

Посмотрели inspect нашего контейнера:<br>

![Инспект](https://github.com/IvanChet-4/Dev/blob/main/images/Homework%201-3/%D0%98%D0%BD%D1%81%D0%BF%D0%B5%D0%BA%D1%82.png)

По заданию удалили файл compose.yaml и получили следующее предупреждение:<br>

```
WARN[0000] /home/user7/netology/docker/task5/docker-compose.yaml: the attribute `version` is obsolete, it will be ignored, please remove it to avoid potential confusion 
WARN[0000] Found orphan containers ([task5-portainer-1]) for this project. If you removed or renamed this service in your compose file, you can run this command with the --remove-orphans flag to clean it up.
```

![Удаление файла ямл](https://github.com/IvanChet-4/Dev/blob/main/images/Homework%201-3/%D0%A3%D0%B4%D0%B0%D0%BB%D0%B5%D0%BD%D0%B8%D0%B5%20%D1%84%D0%B0%D0%B9%D0%BB%D0%B0%20%D1%8F%D0%BC%D0%BB.png)

Выполнили:<br>

```
docker compose up -d --remove-orphans
```

![Выполнение с remove-orphans](https://github.com/IvanChet-4/Dev/blob/main/images/Homework%201-3/%D0%92%D1%8B%D0%BF%D0%BE%D0%BB%D0%BD%D0%B5%D0%BD%D0%B8%D0%B5%20%D1%81%20remove-orphans.png
)

Для остановки контейнера/-ов docker-compose stop<br>
(Для уничтожения контейнера/-ов docker-compose down)<br>

![Остановка](https://github.com/IvanChet-4/Dev/blob/main/images/Homework%201-3/%D0%9E%D1%81%D1%82%D0%B0%D0%BD%D0%BE%D0%B2%D0%BA%D0%B0.png
)

---

### Правила приема

Домашнее задание выполните в файле readme.md в GitHub-репозитории. В личном кабинете отправьте на проверку ссылку на .md-файл в вашем репозитории.
