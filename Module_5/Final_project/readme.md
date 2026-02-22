chmod +x /usr/local/bin/procmon.sh
crontab -e
*/5 * * * * /usr/local/bin/procmon.sh
