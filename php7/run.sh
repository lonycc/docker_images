docker run --name phpfpm7 -p 9002:9000 --privileged=true -d -v /home/www:/var/www/html mydocker/php:7.0