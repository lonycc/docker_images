############################################
# version : mydocker/php:7.0
# desc : 当前版本安装php
############################################
# 设置继承自php官方
FROM php:7.0-fpm

# 下面是一些创建者的基本信息
MAINTAINER tony (tony@163.com)

# 设置环境变量，所有操作都是非交互式的
ENV DEBIAN_FRONTEND noninteractive

# 更改系统的时区设置
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo "Asia/Shanghai" > /etc/timezone

# 添加配置文件
ADD php.ini /usr/local/etc/php/php.ini

# 更新debian软件更新的源服务器的sources.list文件(更新居然会有GPG KEY问题，干脆不更新了)
# COPY sources.list /etc/apt/sources.list
RUN rm -rf /var/lib/apt/lists/*

# php扩展安装工具的一些依赖包写进环境变量
ENV PHPIZE_DEPS \
    autoconf \
    file \
    g++ \
    gcc \
    libc-dev \
    make \
    pkg-config \
    re2c

# 安装各种基础依赖
RUN apt-get update && apt-get install -y \
    $PHPIZE_DEPS \
    ca-certificates \
    curl \
    vim \
    wget \
    libedit2 \
    libsqlite3-0 \
    libxml2 \
    libxml2-dev \
    xz-utils \
    --no-install-recommends && rm -r /var/lib/apt/lists/*

# RUN wget -q http://drbl.nchc.org.tw/GPG-KEY-DRBL -O- | apt-key add -

# php配置路径
ENV PHP_INI_DIR /usr/local/etc/php
RUN mkdir -p $PHP_INI_DIR/conf.d

# 源码解压、安装部署、删除
RUN docker-php-source extract \
    # do important things \
    && docker-php-source delete

# 不能用ADD, 因为ADD会自动解压tar文件
COPY redis-3.1.2.tgz /home/redis-3.1.2.tgz
COPY memcached-3.0.3.tgz /home/memcached-3.0.3.tgz
COPY xdebug-2.5.1.tgz /home/xdebug-2.5.1.tgz

# 安装php的一些依赖库
RUN apt-get update --fix-missing && apt-get install -y \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libmcrypt-dev \
    libpng12-dev \
    libcurl4-gnutls-dev \
    yasm \
    libvpx-dev \
    libtiff5-dev \
    libgd-dev \
    libmemcached-dev \
    zlib1g-dev \
    && docker-php-ext-install -j$(nproc) iconv curl mbstring xml json mcrypt mysqli pdo pdo_mysql zip && docker-php-ext-configure gd --with-libxml-dir=/usr/include/ --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-vpx-dir=/usr/include/ --with-png-dir=/usr/include/ && docker-php-ext-install -j$(nproc) gd && docker-php-ext-enable gd

# 安装标准扩展的一般动作
# RUN docker-php-ext-configure mysql  && docker-php-ext-install mysql  && docker-php-ext-enable mysql

# 通过pecl安装
RUN pecl install /home/redis-3.1.2.tgz \
    && pecl install /home/xdebug-2.5.1.tgz \
    && pecl install /home/memcached-3.0.3.tgz \
    && docker-php-ext-enable redis xdebug memcached

# 这条命令是将用户www-data的uid改为1000
RUN usermod -u 1000 www-data

# 安装composer
ADD composer-setup.php /home/composer-setup.php
RUN cd /home \
    && php composer-setup.php \
    && php -r "unlink('composer-setup.php');" \
    && mv composer.phar /usr/local/bin/composer \
    && composer self-update

# RUN composer config -g repo.packagist composer https://packagist.phpcomposer.com

# 工作目录
WORKDIR /var/www/html

# 这里创建本地挂载点
VOLUME ["/var/www/html"]

EXPOSE 9000