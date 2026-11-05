FROM nginx:1.29.0

COPY ./nginx.conf /etc/nginx/nginx.conf
COPY ./index.html /usr/share/nginx/html
EXPOSE 80

# Запускаем nginx в фоновом режиме (по умолчанию)
CMD ["nginx", "-g", "daemon off;"]
