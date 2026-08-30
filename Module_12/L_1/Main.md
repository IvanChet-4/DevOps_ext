# Домашнее задание к занятию «Уязвимости и атаки на информационные системы»

------

### Задание 1

Скачайте и установите виртуальную машину Metasploitable: https://sourceforge.net/projects/metasploitable/.

Это типовая ОС для экспериментов в области информационной безопасности, с которой следует начать при анализе уязвимостей.

Просканируйте эту виртуальную машину, используя **nmap**.

Попробуйте найти уязвимости, которым подвержена эта виртуальная машина.

Сами уязвимости можно поискать на сайте https://www.exploit-db.com/.

Для этого нужно в поиске ввести название сетевой службы, обнаруженной на атакуемой машине, и выбрать подходящие по версии уязвимости.

### Решение:  

Ответьте на следующие вопросы:  

- Какие сетевые службы в ней разрешены?  

Ниже прикреплен вывод после сканирования командой nmap -sV -p- -Pn IP-target. Все что в столбце SERVICE.  

- Какие уязвимости были вами обнаружены? (список со ссылками: достаточно трёх уязвимостей)  

vsftpd 2.3.4 — Бэкдор для удаленного выполнения команд (порт 21) -  Exploit-DB: EDB-ID 17491 (vsftpd 2.3.4 - Backdoor Command Execution)  

Samba 3.X - 4.X — Удаленное выполнение команд через "Username Map Script" (порты 139/445) Exploit-DB: EDB-ID 16320 (Samba 3.0.20 < 3.0.25rc3 - Command Execution)  

distccd v1 — Удаленное выполнение кода через компилятор (порт 3632) - Exploit-DB: EDB-ID 9915 (DistCC Daemon - Command Execution)  
  

<img width="1085" height="779" alt="image" src="https://github.com/user-attachments/assets/52c004bf-4c69-4bd8-a3a1-55288ae2b1b3" />  

<img width="723" height="411" alt="image" src="https://github.com/user-attachments/assets/55ee2437-a183-48b9-9bff-f7bd2bf8856c" />  
  
```
Not shown: 65505 closed tcp ports (reset)
PORT      STATE SERVICE     VERSION
21/tcp    open  ftp         vsftpd 2.3.4
22/tcp    open  ssh         OpenSSH 4.7p1 Debian 8ubuntu1 (protocol 2.0)
23/tcp    open  telnet      Linux telnetd
25/tcp    open  smtp        Postfix smtpd
53/tcp    open  domain      ISC BIND 9.4.2
80/tcp    open  http        Apache httpd 2.2.8 ((Ubuntu) DAV/2)
111/tcp   open  rpcbind     2 (RPC #100000)
139/tcp   open  netbios-ssn Samba smbd 3.X - 4.X (workgroup: WORKGROUP)
445/tcp   open  netbios-ssn Samba smbd 3.X - 4.X (workgroup: WORKGROUP)
512/tcp   open  exec        netkit-rsh rexecd
513/tcp   open  login
514/tcp   open  tcpwrapped
1099/tcp  open  java-rmi    GNU Classpath grmiregistry
1524/tcp  open  bindshell   Metasploitable root shell
2049/tcp  open  nfs         2-4 (RPC #100003)
2121/tcp  open  ftp         ProFTPD 1.3.1
3306/tcp  open  mysql       MySQL 5.0.51a-3ubuntu5
3632/tcp  open  distccd     distccd v1 ((GNU) 4.2.4 (Ubuntu 4.2.4-1ubuntu4))
5432/tcp  open  postgresql  PostgreSQL DB 8.3.0 - 8.3.7
5900/tcp  open  vnc         VNC (protocol 3.3)
6000/tcp  open  X11         (access denied)
6667/tcp  open  irc         UnrealIRCd
6697/tcp  open  irc         UnrealIRCd
8009/tcp  open  ajp13       Apache Jserv (Protocol v1.3)
8180/tcp  open  http        Apache Tomcat/Coyote JSP engine 1.1
8787/tcp  open  drb         Ruby DRb RMI (Ruby 1.8; path /usr/lib/ruby/1.8/drb)
34878/tcp open  mountd      1-3 (RPC #100005)
38566/tcp open  nlockmgr    1-4 (RPC #100021)
42036/tcp open  java-rmi    GNU Classpath grmiregistry
58149/tcp open  status      1 (RPC #100024)
MAC Address: 08:00:27:97:51:3A (Oracle VirtualBox virtual NIC)
```
  
### Задание 2

Проведите сканирование Metasploitable в режимах SYN, FIN, Xmas, UDP.

Запишите сеансы сканирования в Wireshark.

Ответьте на следующие вопросы:

- Чем отличаются эти режимы сканирования с точки зрения сетевого трафика?
- Как отвечает сервер?

### Решение:

SYN-сканирование: nmap -sS -Pn IP-target  

<img width="587" height="564" alt="image" src="https://github.com/user-attachments/assets/638ed0ff-818c-49e8-931b-76f3b958d128" />  

```
Starting Nmap 7.94SVN ( https://nmap.org ) at 2026-08-30 16:27 EDT
Nmap scan report for 10.0.2.5
Host is up (0.00010s latency).
Not shown: 977 closed tcp ports (reset)
PORT     STATE SERVICE
21/tcp   open  ftp
22/tcp   open  ssh
23/tcp   open  telnet
25/tcp   open  smtp
53/tcp   open  domain
80/tcp   open  http
111/tcp  open  rpcbind
139/tcp  open  netbios-ssn
445/tcp  open  microsoft-ds
512/tcp  open  exec
513/tcp  open  login
514/tcp  open  shell
1099/tcp open  rmiregistry
1524/tcp open  ingreslock
2049/tcp open  nfs
2121/tcp open  ccproxy-ftp
3306/tcp open  mysql
5432/tcp open  postgresql
5900/tcp open  vnc
6000/tcp open  X11
6667/tcp open  irc
8009/tcp open  ajp13
8180/tcp open  unknown
MAC Address: 08:00:27:97:51:3A (Oracle VirtualBox virtual NIC)

Nmap done: 1 IP address (1 host up) scanned in 0.21 seconds
```

FIN-сканирование: nmap -sF -Pn IP-target  
<img width="631" height="534" alt="image" src="https://github.com/user-attachments/assets/85238ae8-e884-4ef2-a507-4633db9f4e41" />  
  
```
Starting Nmap 7.94SVN ( https://nmap.org ) at 2026-08-30 16:29 EDT
Nmap scan report for 10.0.2.5
Host is up (0.000060s latency).
Not shown: 977 closed tcp ports (reset)
PORT     STATE         SERVICE
21/tcp   open|filtered ftp
22/tcp   open|filtered ssh
23/tcp   open|filtered telnet
25/tcp   open|filtered smtp
53/tcp   open|filtered domain
80/tcp   open|filtered http
111/tcp  open|filtered rpcbind
139/tcp  open|filtered netbios-ssn
445/tcp  open|filtered microsoft-ds
512/tcp  open|filtered exec
513/tcp  open|filtered login
514/tcp  open|filtered shell
1099/tcp open|filtered rmiregistry
1524/tcp open|filtered ingreslock
2049/tcp open|filtered nfs
2121/tcp open|filtered ccproxy-ftp
3306/tcp open|filtered mysql
5432/tcp open|filtered postgresql
5900/tcp open|filtered vnc
6000/tcp open|filtered X11
6667/tcp open|filtered irc
8009/tcp open|filtered ajp13
8180/tcp open|filtered unknown
MAC Address: 08:00:27:97:51:3A (Oracle VirtualBox virtual NIC)

Nmap done: 1 IP address (1 host up) scanned in 1.40 seconds
```
Xmas-сканирование: nmap -sX -Pn IP-target  
<img width="646" height="547" alt="image" src="https://github.com/user-attachments/assets/0899369f-7920-48c1-8ecf-a225722a7edd" />  
  
```
Starting Nmap 7.94SVN ( https://nmap.org ) at 2026-08-30 16:30 EDT
Nmap scan report for 10.0.2.5
Host is up (0.00013s latency).
Not shown: 977 closed tcp ports (reset)
PORT     STATE         SERVICE
21/tcp   open|filtered ftp
22/tcp   open|filtered ssh
23/tcp   open|filtered telnet
25/tcp   open|filtered smtp
53/tcp   open|filtered domain
80/tcp   open|filtered http
111/tcp  open|filtered rpcbind
139/tcp  open|filtered netbios-ssn
445/tcp  open|filtered microsoft-ds
512/tcp  open|filtered exec
513/tcp  open|filtered login
514/tcp  open|filtered shell
1099/tcp open|filtered rmiregistry
1524/tcp open|filtered ingreslock
2049/tcp open|filtered nfs
2121/tcp open|filtered ccproxy-ftp
3306/tcp open|filtered mysql
5432/tcp open|filtered postgresql
5900/tcp open|filtered vnc
6000/tcp open|filtered X11
6667/tcp open|filtered irc
8009/tcp open|filtered ajp13
8180/tcp open|filtered unknown
MAC Address: 08:00:27:97:51:3A (Oracle VirtualBox virtual NIC)

Nmap done: 1 IP address (1 host up) scanned in 1.42 seconds
```
UDP-сканирование: nmap -sU -p 53,111,137 -Pn IP-target  
<img width="565" height="240" alt="image" src="https://github.com/user-attachments/assets/29a1427a-005c-41a7-8910-b5413538e471" />  
  
```
Starting Nmap 7.94SVN ( https://nmap.org ) at 2026-08-30 16:31 EDT
Nmap scan report for 10.0.2.5
Host is up (0.00029s latency).

PORT    STATE SERVICE
53/udp  open  domain
111/udp open  rpcbind
137/udp open  netbios-ns
MAC Address: 08:00:27:97:51:3A (Oracle VirtualBox virtual NIC)

Nmap done: 1 IP address (1 host up) scanned in 0.24 seconds
```
