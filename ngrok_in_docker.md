# build image 

`git clone https://github.com/hteen/docker-ngrok.git`

`cd docker-ngrok`

`docker build -t hteen/ngrok .`

**run**
```
docker run -idt --name ngrok-server \
-v /home/opt/ngrok:/myfiles \
-e DOMAIN='ngrok.domain.com' hteen/ngrok /bin/sh /server.sh
```

**dockerfile**
```
FROM golang:1.7.1-alpine
MAINTAINER hteen <i@hteen.cn>

RUN apk add --no-cache git make openssl

RUN git clone https://github.com/tutumcloud/ngrok.git /ngrok

ADD *.sh /

ENV DOMAIN **None**
ENV MY_FILES /myfiles
ENV TUNNEL_ADDR :4443
ENV HTTP_ADDR :80
ENV HTTPS_ADDR :443

EXPOSE 4443
EXPOSE 80
EXPOSE 443

CMD /bin/sh
```

<br/>

## 启动一个容器生成ngrok客户端, 服务器端和CA证书

```
docker run --rm -it -e DOMAIN="ngrok.domain.com" \
-v /home/opt/ngrok:/myfiles hteen/ngrok /bin/sh /build.sh
```

## 启动服务端

```
docker run -idt --name ngrok-server \
-v /home/opt/ngrok:/myfiles \
-p 8082:80 \
-p 4432:443 \
-p 4443:4443 \
-e DOMAIN='ngrok.domain.com' hteen/ngrok /bin/sh /server.sh
```

## 域名解析

> 需要添加两条A记录, `*.ngrok`和`ngrok`, 这样才能将`ngrok.domain.com`和`*.ngrok.domain.com` DNS解析到服务器.

## 客户端连接

> 从`/home/opt/ngrok`下载生成的客户端, 创建一个配置文件`ngrok.cfg`, 配置如下

> server_addr: "ngrok.domain.com:4443"

> trust_host_root_certs: false

然后执行命令`./ngrok -config ./ngrok.cfg -subdomain wechat 192.168.0.8:80`, 这样就将`wechat.ngrok.domain.com`绑定到了本地`192.168.0.8:80`

## nginx配置

```
server {
     listen       80;
     server_name  ngrok.domain.com *.ngrok.domain.com;
     location / {
             proxy_redirect off;
             proxy_set_header Host $host;
             proxy_set_header X-Real-IP $remote_addr;
             proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
             proxy_pass http://127.0.0.1:8082;
     }
 }
 
 server {
     listen       443;
     server_name  ngrok.domain.com *.ngrok.domain.com;
     location / {
             proxy_redirect off;
             proxy_set_header Host $host;
             proxy_set_header X-Real-IP $remote_addr;
             proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
             proxy_pass http://127.0.0.1:4432;
     }
 }
```
