chmod +x /usr/local/bin/procmon.sh  
crontab -e

```

*/5 * * * * /usr/local/bin/procmon.sh

```

sudo apt install inotify-tools  
sudo chmod +x /usr/local/bin/dev_monitor.sh  
/usr/local/bin/dev_monitor.sh  
sudo nano /etc/cron.d/dev_monitor  

```

#Опрос /proc/bus/input каждую минуту
* * * * * root /usr/local/bin/dev_monitor.sh >> /var/log/dev_monitor.log 2>&1

```

tail -f /var/log/dev_monitor.log
