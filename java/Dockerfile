############################################
# version : mydocker/java:8.0
# desc : 当前版本安装的java
############################################
# 设置继承自我们创建的 tools 镜像
FROM mydocker/tools:v1

# 下面是一些创建者的基本信息
MAINTAINER tony (tony@163.com)

# 设置环境变量，所有操作都是非交互式的
ENV DEBIAN_FRONTEND noninteractive

# 添加 supervisord 的配置文件，并复制配置文件到对应目录下面。（supervisord.conf文件和Dockerfile文件在同一路径）
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN mkdir -p /usr/local/jdk8 && mkdir -p /usr/local/tomcat8

ADD jdk1.8.0_121 /usr/local/jdk8
ADD tomcat-8.5.12 /usr/local/tomcat8

ENV JAVA_HOME /usr/local/jdk8
ENV CATALINA_HOME /usr/local/tomcat8

RUN echo "JAVA_HOME=/usr/local/jdk8" >> ~/.bashrc \
    && echo "CLASSPATH=.:$JAVA_HOME/lib/tools.jar" >> ~/.bashrc \
    && echo "PATH=$JAVA_HOME/bin:$PATH" >> ~/.bashrc \
    && echo "export JAVA_HOME CLASSPATH PATH" >> ~/.bashrc
    # && /etc/profile

EXPOSE 8080

VOLUME ["/usr/local/tomcat8/webapps", "/usr/local/tomcat8/logs", "/usr/local/tomcat8/conf"]

# 执行supervisord来同时执行多个命令，使用 supervisord 的可执行路径启动服务。
CMD ["/usr/bin/supervisord"]