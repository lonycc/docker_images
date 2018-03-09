############################################
# version : mydocker/mongodb:3.0.7
# desc : 当前版本安装的mongodb
############################################
# 设置继承自我们创建的 tools 镜像
FROM mydocker/tools:v1

# 下面是一些创建者的基本信息
MAINTAINER tony (tony@163.com)

# 设置环境变量，所有操作都是非交互式的
ENV DEBIAN_FRONTEND noninteractive

# 添加 supervisord 的配置文件，并复制配置文件到对应目录下面。（supervisord.conf文件和Dockerfile文件在同一路径）
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# 创建目录
RUN mkdir -p /usr/local/mongodb

# 设置 mongo 的环境变量，若读者有其他的环境变量需要设置，也可以在这里添加。
ENV MONGO_HOME /usr/local/mongodb
ENV LC_ALL C

# 复制 mongo-3.0.7 文件夹到镜像中
ADD mongo-3.0.7 /usr/local/mongodb
ADD mongo.conf /usr/local/redis/mongo.conf

# 挂载本地目录
VOLUME ["/usr/local/mongodb/data"]

# 容器需要开放Mongo 30000端口
EXPOSE 30000

# 执行supervisord来同时执行多个命令，使用 supervisord 的可执行路径启动服务。
CMD ["/usr/bin/supervisord"]