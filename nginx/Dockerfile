############################################
# version : mydocker/nginx:1.10.3
# desc : 当前版本安装的nginx
############################################
# 设置继承自我们创建的 tools 镜像
FROM mydocker/tools:v1

# 下面是一些创建者的基本信息
MAINTAINER tony (tony@163.com)

# 设置环境变量，所有操作都是非交互式的
ENV DEBIAN_FRONTEND noninteractive

# 添加 supervisord 的配置文件，并复制配置文件到对应目录下面。（supervisord.conf文件和Dockerfile文件在同一路径）
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# 安装升级gcc
RUN sudo rm -rf /var/lib/apt/lists/*
RUN sudo apt-get update
RUN sudo apt-get -y install build-essential

# 移动文件
COPY nginx-1.10.3.tar.gz /home/package/nginx-1.10.3.tar.gz
COPY openssl-1.0.1q.tar.gz /home/package/openssl-1.0.1q.tar.gz
COPY pcre-8.39.tar.gz /home/package/pcre-8.39.tar.gz
COPY zlib-1.2.11.tar.gz /home/package/zlib-1.2.11.tar.gz

RUN groupadd www && useradd -g www -s /bin/false -d /usr/local/nginx/html www

# 编译安装nginx
RUN sudo mkdir -p /home/package
RUN sudo mkdir -p /usr/local/nginx
RUN cd /home/package && tar -zxvf nginx-1.10.3.tar.gz -C /home/package \
    && tar -zxvf zlib-1.2.11.tar.gz -C /home/package \
    && tar -zxvf openssl-1.0.1q.tar.gz -C /home/package \
    && tar -zxvf pcre-8.39.tar.gz -C /home/package \
    && cd /home/package/nginx-1.10.3 && sudo ./configure --prefix=/usr/local/nginx --user=www --group=www --sbin-path=/usr/local/nginx/sbin/nginx \
     --conf-path=/usr/local/nginx/conf/nginx.conf --pid-path=/usr/local/nginx/logs/nginx.pid --without-http_memcached_module --with-http_ssl_module \
     --with-http_realip_module --with-http_addition_module --with-http_sub_module --with-http_dav_module --with-http_flv_module --with-http_mp4_module \
     --with-http_gzip_static_module --with-http_random_index_module --with-http_secure_link_module --with-http_stub_status_module \
     --with-http_auth_request_module --with-threads --with-stream --with-stream_ssl_module --with-http_slice_module --with-mail --with-mail_ssl_module \
     --with-file-aio --with-http_v2_module --with-ipv6 --with-pcre=/home/package/pcre-8.39 --with-zlib=/home/package/zlib-1.2.11 \
     --with-openssl=/home/package/openssl-1.0.1q \
    && sudo make && sudo make install

# 设置nginx是非daemon启动
RUN echo 'daemon off;' >> /usr/local/nginx/conf/nginx.conf \
    && echo 'master_process off;' >> /usr/local/nginx/conf/nginx.conf \
    && echo 'error_log  logs/error.log;' >> /usr/local/nginx/conf/nginx.conf

# 设置 NGINX 的环境变量，若读者有其他的环境变量需要设置，也可以在这里添加。
ENV NGINX_HOME /usr/local/nginx

# 容器需要开放Nginx 80端口
EXPOSE 80

# 挂载目录
VOLUME ["/usr/local/nginx/conf.d", "/usr/local/nginx/conf", "/usr/local/nginx/logs", "/usr/local/nginx/html"]

# 执行run.sh文件
# CMD ["/run.sh"]
# 执行supervisord来同时执行多个命令，使用 supervisord 的可执行路径启动服务。
CMD ["/usr/bin/supervisord"]
