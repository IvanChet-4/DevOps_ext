# Задание 1

1. Скриншот авторизации в админке  
  
<img width="1600" height="891" alt="image" src="https://github.com/user-attachments/assets/6194d563-dd6c-4fef-96b5-3599d4d566b0"  />
  
2. Установка по инструкции с https://www.zabbix.com/ru/download?zabbix=7.0&os_distribution=ubuntu&os_version=24.04&components=server_frontend_agent&db=pgsql&ws=nginx  
  
3. Список команд  
- wget https://repo.zabbix.com/zabbix/7.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest_7.0+ubuntu24.04_all.deb  
- dpkg -i zabbix-release_latest_7.0+ubuntu24.04_all.deb  
- apt update  
- apt install zabbix-server-pgsql zabbix-frontend-php php8.3-pgsql zabbix-nginx-conf zabbix-sql-scripts zabbix-agent  
- apt install postgresql-16  
- sudo -u postgres createuser --pwprompt zabbix  
- sudo -u postgres createdb -O zabbix zabbix  
- zcat /usr/share/zabbix-sql-scripts/postgresql/server.sql.gz | sudo -u zabbix psql zabbix  
- nano /etc/zabbix/zabbix_server.conf  
- nano /etc/zabbix/nginx.conf   
- systemctl restart zabbix-server zabbix-agent nginx php8.3-fpm  
- systemctl enable zabbix-server zabbix-agent nginx php8.3-fpm   
  
# Задание 2

Список команд установки  
- wget https://repo.zabbix.com/zabbix/7.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest_7.0+ubuntu24.04_all.deb  
- dpkg -i zabbix-release_latest_7.0+ubuntu24.04_all.deb    
- apt update    
- apt install zabbix-agent2
- apt install zabbix-agent2-plugin-postgresql
- nano /etc/zabbix/zabbix_agent2.conf   
- systemctl restart zabbix-agent2  
- systemctl enable zabbix-agent2



<img width="1908" height="791" alt="image" src="https://github.com/user-attachments/assets/91721b6d-4978-42fd-9b7b-0070bb67ccbf" />

<img width="824" height="588" alt="image" src="https://github.com/user-attachments/assets/d595b6fa-5b48-4c4f-bd96-993c746b623e" />

<img width="1834" height="943" alt="image" src="https://github.com/user-attachments/assets/ee8dd372-c339-4169-9c7f-a44320553249" />

<img width="1870" height="923" alt="image" src="https://github.com/user-attachments/assets/a7293e43-c5d0-4db8-b1e0-b91d870ecc6f" />



  
# Задание 3  
  
<img width="1637" height="778" alt="image" src="https://github.com/user-attachments/assets/05494e45-adb6-4c3f-832f-c58a73a4d90c" />
  
<img width="1832" height="545" alt="image" src="https://github.com/user-attachments/assets/f1ec7a27-a533-4490-b9ea-872bd0b63251" />  

