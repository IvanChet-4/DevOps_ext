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

- wget https://repo.zabbix.com/zabbix/7.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest_7.0+ubuntu24.04_all.deb
