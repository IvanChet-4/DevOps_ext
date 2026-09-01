
# Домашнее задание к занятию «Защита сети»

------

### Подготовка к выполнению заданий

1. Подготовка защищаемой системы:

- установите **Suricata**,

<img width="1515" height="591" alt="image" src="https://github.com/user-attachments/assets/a27804d4-c02d-4cea-afdb-0fe4cf67c9a8" />


- установите **Fail2Ban**.

<img width="1519" height="504" alt="image" src="https://github.com/user-attachments/assets/85023884-e0f4-40b2-96db-1c5ea1f04e11" />


Вывод с term.log

<img width="1241" height="575" alt="image" src="https://github.com/user-attachments/assets/74374626-5b24-447a-ac48-c2443cd94cba" />

<img width="1485" height="809" alt="image" src="https://github.com/user-attachments/assets/ee7872bd-0111-46f5-910c-7f607981f1a5" />


2. Подготовка системы злоумышленника: установите **nmap** и **thc-hydra** либо скачайте и установите **Kali linux**.

Обе системы должны находится в одной подсети.

<img width="848" height="592" alt="image" src="https://github.com/user-attachments/assets/122b5ac2-571d-442c-9572-127fa06eb291" />


------

### Задание 1

### Решение:

Проведите разведку системы и определите, какие сетевые службы запущены на защищаемой системе:

**sudo nmap -sA < ip-адрес >**

<img width="561" height="197" alt="image" src="https://github.com/user-attachments/assets/721b37c4-87f8-4e99-8162-c15bef7e92ce" />

```
Starting Nmap 7.94SVN ( https://nmap.org ) at 2026-08-30 18:40 EDT
Nmap scan report for 10.0.2.6
Host is up (0.00014s latency).
All 1000 scanned ports on 10.0.2.6 are in ignored states.
Not shown: 1000 unfiltered tcp ports (reset)
MAC Address: 08:00:27:5C:39:61 (Oracle VirtualBox virtual NIC)

Nmap done: 1 IP address (1 host up) scanned in 0.16 seconds
```

**sudo nmap -sT < ip-адрес >**

<img width="589" height="219" alt="image" src="https://github.com/user-attachments/assets/d4b01ae1-e4c8-4fbd-939c-4331068a0f70" />

```
Starting Nmap 7.94SVN ( https://nmap.org ) at 2026-08-30 18:42 EDT
Nmap scan report for 10.0.2.6
Host is up (0.00019s latency).
Not shown: 998 closed tcp ports (conn-refused)
PORT   STATE SERVICE
22/tcp open  ssh
80/tcp open  http
MAC Address: 08:00:27:5C:39:61 (Oracle VirtualBox virtual NIC)

Nmap done: 1 IP address (1 host up) scanned in 0.17 seconds
```

**sudo nmap -sS < ip-адрес >**

<img width="583" height="218" alt="image" src="https://github.com/user-attachments/assets/147648c2-806c-4204-a605-bf4b3525e3df" />

```
Starting Nmap 7.94SVN ( https://nmap.org ) at 2026-08-30 18:43 EDT
Nmap scan report for 10.0.2.6
Host is up (0.0014s latency).
Not shown: 998 closed tcp ports (reset)
PORT   STATE SERVICE
22/tcp open  ssh
80/tcp open  http
MAC Address: 08:00:27:5C:39:61 (Oracle VirtualBox virtual NIC)

Nmap done: 1 IP address (1 host up) scanned in 0.19 seconds
```

**sudo nmap -sV < ip-адрес >**

<img width="793" height="246" alt="image" src="https://github.com/user-attachments/assets/72c54996-056d-4402-ba33-1164181a75cd" />

```
Starting Nmap 7.94SVN ( https://nmap.org ) at 2026-08-30 18:44 EDT
Nmap scan report for 10.0.2.6
Host is up (0.00017s latency).
Not shown: 998 closed tcp ports (reset)
PORT   STATE SERVICE VERSION
22/tcp open  ssh     OpenSSH 9.6p1 Ubuntu 3ubuntu13.18 (Ubuntu Linux; protocol 2.0)
80/tcp open  http    Apache httpd 2.4.58 ((Ubuntu))
MAC Address: 08:00:27:5C:39:61 (Oracle VirtualBox virtual NIC)
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 6.39 seconds
```

По желанию можете поэкспериментировать с опциями: https://nmap.org/man/ru/man-briefoptions.html.


*В качестве ответа пришлите события, которые попали в логи Suricata и Fail2Ban, прокомментируйте результат.*

2026-08-31 02:11:14,941 fail2ban.filter         [35663]: INFO    [suricata] Found 10.0.2.4 - 2026-08-31 02:11:14  
2026-08-31 02:11:15,030 fail2ban.actions        [35663]: WARNING [suricata] 10.0.2.4 already banned  
2026-08-31 02:11:15,176 fail2ban.filter         [35663]: INFO    [suricata] Found 10.0.2.4 - 2026-08-31 02:11:15  
2026-08-31 02:11:15,237 fail2ban.actions        [35663]: WARNING [suricata] 10.0.2.4 already banned  

Строки WARNING [suricata] 10.0.2.4 already banned («уже заблокирован») — nmap продолжал слать последующие пакеты для разведки (например, пытаясь определить версии служб с помощью -sV), система их уже не пропускала.   
Хост был изолирован на сетевом уровне, что полностью ослепило атакующего.


<img width="1212" height="643" alt="image" src="https://github.com/user-attachments/assets/6f056fb7-7bfb-4a47-ae32-baa349c9349e" />

------

### Задание 2

Проведите атаку на подбор пароля для службы SSH:

**hydra -L users.txt -P pass.txt < ip-адрес > ssh**

1. Настройка **hydra**: 
 
 - создайте два файла: **users.txt** и **pass.txt**;
 - в каждой строчке первого файла должны быть имена пользователей, второго — пароли. В нашем случае это могут быть случайные строки, но ради эксперимента можете добавить имя и пароль существующего пользователя.

Дополнительная информация по **hydra**: https://kali.tools/?p=1847.

2. Включение защиты SSH для Fail2Ban:

-  открыть файл /etc/fail2ban/jail.conf,
-  найти секцию **ssh**,
-  установить **enabled**  в **true**.

Дополнительная информация по **Fail2Ban**:https://putty.org.ru/articles/fail2ban-ssh.html.

*В качестве ответа пришлите события, которые попали в логи Suricata и Fail2Ban, прокомментируйте результат.*

### Решение:  

1. Если защита выключена:  

<img width="1588" height="255" alt="image" src="https://github.com/user-attachments/assets/cbce2a19-e9f8-4af0-8353-d4f03cfbe95c" />


2. Защита включена:  

<img width="677" height="241" alt="image" src="https://github.com/user-attachments/assets/91d2097e-8a12-4fb8-b4b8-94e1abaa53c5" />

<img width="678" height="248" alt="image" src="https://github.com/user-attachments/assets/4127b350-1fc8-47c4-ae91-f1fddf5dc087" />

<img width="1609" height="281" alt="image" src="https://github.com/user-attachments/assets/19f9e3c5-b012-4adc-a91a-b32117c22372" />

<img width="1333" height="261" alt="image" src="https://github.com/user-attachments/assets/57f34f80-c6be-4392-a60b-45dacd5b43e5" />

Строка WARNING [suricata] 10.0.2.6 already banned подтверждает, что атакующий хост превысил лимит попыток (maxretry) в первые секунды атаки. Fail2ban заблокировал его на уровне брандмауэра.  
