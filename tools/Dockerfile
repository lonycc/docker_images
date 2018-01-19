############################################
# version : mydocker/tools:v1
# desc : 当前版本安装的ssh，wget，curl，supervisor
############################################
# 设置继承自ubuntu官方镜像
FROM ubuntu:latest

# 下面是一些创建者的基本信息
MAINTAINER tony (tony@163.com)

# 设置环境变量，所有操作都是非交互式的
ENV DEBIAN_FRONTEND noninteractive

# 更改系统的时区设置
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo "Asia/Shanghai" > /etc/timezone

# 清空ubuntu更新包
RUN rm -rf /var/lib/apt/lists/*

# 一次性安装vim，wget，curl，ssh server等必备软件
# RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe"> /etc/apt/sources.list
RUN apt-get update
RUN apt-get install -y vim wget curl openssh-server sudo
RUN mkdir -p /var/run/sshd

# 将sshd的UsePAM参数设置成no
RUN sed -i 's/UsePAM yes/UsePAM no/g' /etc/ssh/sshd_config

# 添加测试用户admin, 密码yourpassword，并且将此用户添加到sudoers里
RUN useradd admin
RUN echo "yourpassword" | chpasswd
RUN echo "admin   ALL=(ALL)       ALL" >> /etc/sudoers

# 把admin用户的shell改成bash，否则SSH登录Ubuntu服务器，命令行不显示用户名和目录
RUN usermod -s /bin/bash admin

# 安装supervisor工具
RUN apt-get install -y supervisor
RUN mkdir -p /var/log/supervisor

# 安装定时任务工具
RUN apt-get install -y cron

# 系统语言设置
RUN locale-gen en_US.UTF-8
RUN echo "LANG=\"en_US.UTF-8\"" >> /etc/default/locale
RUN echo "LANGUAGE=\"en_US:en\"" >> /etc/default/locale

# 添加 supervisord 的配置文件, 并复制配置文件到对应目录下面.（supervisord.conf文件和Dockerfile文件在同一路径）
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# 容器需要开放SSH 22端口
EXPOSE 22

# 执行supervisord来同时执行多个命令, 使用 supervisord 的可执行路径启动服务.
CMD ["/usr/bin/supervisord"]
