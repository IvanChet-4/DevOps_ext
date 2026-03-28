bitnami - недоступен с российского ip, образ взят не от туда в нем нет ps или top, поэтому если команд:  
kubectl exec deployment/redis -- ls /proc  
kubectl exec deployment/redis -- redis-cli info  
недостаточно, то:  
kubectl exec deployment/redis -- sh -c "sed -i 's/deb.debian.org/archive.debian.org/g' /etc/apt/sources.list && sed -i 's/security.debian.org/archive.debian.org/g' /etc/apt/sources.list && sed -i '/stretch-updates/d' /etc/apt/sources.list && apt-get update -o Acquire::Check-Valid-Until=false && apt-get install -y procps"  
kubectl exec deployment/redis -- apt-get update  
kubectl exec deployment/redis -- apt-get install -y procps  
kubectl exec -it deployment/redis -- ps aux  
