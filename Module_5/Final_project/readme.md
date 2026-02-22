chmod +x /usr/local/bin/procmon.sh

crontab -e

```
*/5 * * * * /usr/local/bin/procmon.sh
```

sudo apt install inotify-tools
sudo chmod +x /usr/local/bin/usb_monitor.sh
/usr/local/bin/usb_monitor.sh
sudo nano /etc/cron.d/usb_monitor

```
#Опрос /proc/bus/input каждую минуту
* * * * * root /usr/local/bin/usb_monitor.sh --daemon >> /var/log/usb_monitor.log 2>&1
```

tail -f /var/log/usb_monitor.log
