Проверка доступа по ssh: ansible webservers -i inventory.ini -m ping -u user -k  
Проверка синтаксиса: ansible-playbook my_playbook.yml -i inventory.ini --syntax-check  
Запуск плейбука (motd.yml для примера): ansible-playbook motd.yml -i inventory.ini -u user -k -K -vvv  
Выполнение проверочной команды на хосте из inventory: ansible webservers -i inventory.ini -m command -a "cat /etc/motd" -u user -k  
