docker run --name docker-nginx -p 80:80 --restart always --privileged=true -d -v /home/www:/usr/local/nginx/html -v /home/opt/nginx/logs:/usr/local/nginx/logs -v /home/opt/nginx/conf.d:/usr/local/nginx/conf.d --link phpfpm56:php56 --link phpfpm7:php7 mydocker/nginx:1.10.3
# 注意，自己编译的nginx镜像，nginx.conf可能无法使用include conf.d/*.conf
