# docker_images
docker镜像, 整理一下我制作的一些常用镜像, 以及一些文档说明


## docker部署

**1. 更新源**

`sudo yum update`

**2. 配置docker的yum源**
```
sudo tee /etc/yum.repos.d/docker.repo <<-'EOF'
[dockerrepo]
name=Docker Repository
baseurl=https://yum.dockerproject.org/repo/main/centos/7/
enabled=1
gpgcheck=1
gpgkey=https://yum.dockerproject.org/gpg
EOF
```

> 新版的 Docker 使用 /etc/docker/daemon.json（Linux）来配置 Daemon, 请在该配置文件中加入(没有该文件的话, 请先建一个):

```
{
 "insecure-registries": ["192.168.0.5:5000"],
 "registry-mirrors": ["https://docker.mirrors.ustc.edu.cn"]
}
```

**3. 安装docker包**

`sudo yum install docker-engine`

**4. 启用服务**

`sudo systemctl enable docker.service`

**5. 启动docker进程**

`sudo systemctl start docker`

**6. 确认docker安装正确**

`sudo docker run --rm hello-world` #容器结束后删除数据

`sudo docker run -it ubuntu bash`  #运行一个docker镜像并进入容器

> 注意：若使用官方脚本安装,则2到3步骤可以用命令 `curl -fsSL https://get.docker.com/ | sh` 代替

**7. 安装docker-compose**
```
curl -L https://github.com/docker/compose/releases/download/1.18.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose

chmod +x /usr/local/bin/docker-compose

docker-compose --version
```

**8. 安装gitlab**

- docker-compose 方式安装

`wget https://raw.githubusercontent.com/sameersbn/docker-gitlab/master/docker-compose.yml` #下载配置文件

`docker-compose up`  #启动

<br>

- 分步安装

**(1). 下载镜像**

`docker pull sameersbn/gitlab:latest`

`docker pull sameersbn/redis:latest`

`docker pull sameersbn/mysql:latest`

**(2). 安装mysql**

```
docker run --name gitlab-mysql -d \
    -e 'DB_NAME=gitlabhq_production' \
    -e 'DB_USER=gitlab' \
    -e 'DB_PASS=yourpass' \
    -v /home/opt/mysql/data:/var/lib/mysql \
    sameersbn/mysql:latest
```

**(3). 安装redis**
```
docker run --name gitlab-redis -d \
    -v /home/opt/redis:/var/lib/redis \
    sameersbn/redis:latest
```

**(4). 安装gitlab**
```
docker run --name gitlab -d \
    --link gitlab-mysql:mysql \
    --link gitlab-redis:redisio \
    --publish 10022:22 \
    --publish 10080:80 \
    -e 'GITLAB_PORT=10080' \
    -e 'GITLAB_SSH_PORT=10022' \
    -e 'GITLAB_BACKUPS=daily' \
    -e 'GITLAB_BACKUP_TIME=01:00' \
    -e 'GITLAB_HOST=git.domain.com' \
    -e 'GITLAB_SECRETS_DB_KEY_BASE=long_hash_string' \
    -e 'GITLAB_SECRETS_SECRET_KEY_BASE=long_hash_string' \
    -e 'GITLAB_SECRETS_OTP_KEY_BASE=long_hash_string' \
    -e 'TZ=Asia/Shanghai' \
    -e 'GITLAB_TIMEZONE=Beijing' \
    -v /home/opt/gitlab/data:/home/git/data \
    -v /home/opt/gitlab/log:/home/git/log \
    sameersbn/gitlab:latest
```

**(5). 启动服务**

`docker start gitlab-redis`

`docker start gitlab-mysql`

`docker start gitlab`

<br/><br/>


**9. 安装docker管理工具**

`docker run -d -p 9000:9000 --privileged -v /var/run/docker.sock:/var/run/docker.sock uifd/ui-for-docker:latest`

`http://<docker-ui-host>:9000`  #访问地址

**10. [docker常用命令](http://blog.csdn.net/iloveyin/article/details/40542431)**
```
docker version #查看版本
docker info  #查看docker信息
docker search image_name  #查找镜像
docker top container_name #查看运行容器进程信息
docker cp container_id:/path local_path #从容器里面拷贝文件/目录到宿主路径
docker history image_name #查看镜像历史
docker diff image_name #列出镜像更改

docker pull image_name  #拉取镜像
docker images  #查看所有镜像
docker ps -a  #查看所有容器运行情况
docker ps -l  #查看最近一个启动的容器
docker logs container_name  #查看容器日志
docker port container_name [container_port] #查看本地端口与容器端口映射关系
docker export container_name|container_id > /home/memcached.tar  #导出容器
cat /home/memcached.tar | sudo docker import - memcached:latest  #导入容器
docker save image_name|image_id > /home/memcached-images.tar  #导出镜像
docker load < /home/memcached-images.tar  #加载镜像

docker rmi image_name|image_id #删除指定镜像, -f强制删除
docker rm $(docker ps -a -q)  #删除所有未运行的docker容器
docker rm container_id|container_name #删除指定容器, -f强制删除
docker rmi $(docker images -q)  #删除所有镜像
docker exec -it gitlab bash #进入docker容器的bash环境
docker inspect container_id  #查看容器的各种信息
docker start|stop|kill container_name|container_id  #启动|停止|杀死容器

docker run -it busybox #运行busybox镜像并进入容器, 前台模式
docker run -a stidin -a stdout -i -t ubuntu /bin/bash
-a=[]  ;attach to
-t=false  ;allocate a pseudo-tty
-i=false ;keep STDIN even if not attached
`--restart always` #故障自动重启

`-m|--memory 100m` #内存限制, 最小为4m

`--memory-swap 200m`  #内存加交换分区大小总限制, 必须大于`-m`

`--memory-reservation 50m` #内存的软性限制, 格式同上

`--memory-swappiness` #用于设置容器的虚拟内存控制行为, 0~100之间的整数

`--kernel-memory 50m` #核心内存限制, 最小为4m

`--oom-kill-disable` #是否阻止OOM killer杀死容器, 默认没设置, 最好搭配-m使用

`--oom-score-adj` #容器被OOM killer杀死的优先级, [-1000, 1000], 默认为0

`-cpuset-cpus=7` #允许使用的cpu集, 值在cpu核心数范围内

`-c|--cpu-shares=0` #cpu共享权值

`--cpu-period=0` #cpu cfs的周期

`--cpu-quota=0` #限制cpu cfs的配额

`--cpuset-mems` #内存节点

# 如果不设置`-m`和`--memory-swap`, 容器默认能用完宿主机内存和swap分区, 不过可能会被宿主机杀死(`--oom-kill-disable=false`的情况下).

# 在设置内存限制时, 可能会报错, 这是因为宿主机内核相关功能没有开启.

`vi /etc/default/grub`

`GRUB_CMDLINE_LINUX="cgroup_enable=memory swapaccount=1"`

`sudo grub-mkconfig -o /boot/grub/grub.cfg`

`sudo grub2-mkconfig -o /boot/grub2/grub.cfg`

然后要重启系统.

docker run -itd busybox #-d表示分离shell, 后台模式, 不可使用--rm参数
docker attach container_id #进入上面分离的shell
```

**11. docker部署php-fpm**
```
# 部署php5.5
docker run --name phpfpm55 -p 9000:9000 -d -v /home/www:/var/www/html:rw php:5.5-fpm
# 部署php5.6
docker run --name phpfpm56 -p 9001:9000 -d -v /home/www:/var/www/html:rw php:5.6-fpm
# 部署php7.1
docker run --name phpfpm7 -p 9002:9000 -d -v /home/www:/var/www/html:rw php:7.1-fpm

其中phpfpm是容器名, /home/www是本地php脚本存储目录, /var/www/html是容器内php脚本存储目录, ro表示只读, php:5.6-fpm表示镜像地址.

# 考虑到官方的php镜像很多扩展都没有，需要手动安装
docker exec -it phpfpm55 bash
cd /usr/local/bin
./docker-php-ext-configure pdo_mysql pdo mysql curl gd
./docker-php-ext-install pdo_mysql pdo mysql curl gd
./docker-php-ext-enabled pdo_mysql pdo mysql curl gd

## 安装gd库提示找不到png.h
apt-get update  #这一步很重要, 先更新源
apt-cache search libpng
apt-get install libpng12-dev

## 安装memcached/redis/xdebug等扩展
apt-get install -y libmemcached-dev zlib1g-dev
pecl install memcached-2.2.0 redis-3.1.0 xdebug-2.5.0
docker-php-ext-enabld memcached redis xdebug
```

**12. 本地nginx配置文件**

`vi /home/opt/nginx/conf.d/default.conf`

```
server {
    listen       80;
    server_name  localhost;

    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
    }

    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }

    location ~ \.php$ {
        fastcgi_pass   php55:9000;
        fastcgi_index  index.php;
        fastcgi_param  SCRIPT_FILENAME  /var/www/html$fastcgi_script_name;
        include        fastcgi_params;
    }
}
server {
    listen 80;
    server_name demo;

    ...

    location ~ \.php$ {
        fastcgi_pass php7:9000;
        ...
    }
}
```

**13. docker部署nginx**
```
docker run --name nginx -p 80:80 -d -v /home/www:/usr/share/nginx/html:ro -v /home/opt/nginx/conf.d:/etc/nginx/conf.d:ro --link phpfpm56:php56 --link phpfpm55:php55 --link phpfpm7:php7 nginx

其中 -p 80:80 用于端口映射, 把nginx容器中的80端口暴露出来;
/home/www 是本地html文件的存储目录;
/usr/share/nginx/html 是容器内html文件的存储目录;
/home/opt/nginx/conf.d 是本地nginx配置文件存储目录;
/etc/nginx/conf.d 是容器内nginx配置文件存储目录;
--link phpfpm55:php55 把phpfpm56的网络并入nginx, 并通过修改nginx容器的/etc/hosts, 把域名php55映射成127.0.0.1, 让nginx容器通过php55:9000去访问php-fpm.
```

**14. 测试nginx+phpfpm**

> 在/home/www目录下放入测试文件index.html和index.php即可.


**mysql**

`docker run --name docker-mysql -p 3306:3306 -e MYSQL_ROOT_PASSWORD=docker_passwd -v /home/opt/docker-mysql/data:/var/lib/mysql -d mysql:latest`

**redis**

`docker run --name docker-redis -p 6379:6379 -v /home/opt/docker-redis:/var/lib/redis -d redis:latest`

**memcached**

`docker run --name docker-memcached -p 11211:11211 -v /home/opt/docker-memcached:/var/lib/memcached -u daemon -d memcached:latest`

**elasticsearch**

`docker run --name docker-es -p 9200:9200 -p 9300:9300 -v /home/opt/elasticsearch:/usr/share/elasticsearch/data -d elasticsearch:latest`

**elasticsearch-head**

`docker run --name es-head -p 9100:9100 -d mobz/elasticsearch-head:5`

**[jenkins](http://www.jianshu.com/p/8b1241a90d7a)**

`docker run -d --name jenkins -p 8080:8080 -p 50000:50000 -v /home/opt/jenkins:/var/jenkins_home --link gitlab:gitlab.domain.com -u root jenkins/jenkins:latest`

**bind**

`docker run --name bind -d --restart=always --publish 53:53/tcp --publish 53:53/udp --publish 10000:10000/tcp --volume /opt/docker/bind:/data sameersbn/bind:latest`

**bind测试是否正常的方法**

> 找一台机器, 将其dns设为bind服务所在机器的ip, 执行nslookup www.baidu.com, 如果能正常返回则正常.

**16.docker容器的备份和恢复**
```
# 备份容器
docker ps
docker commit -p [container_id] [container_backup]
docker images

# 可选择推送到docker容器中心
docker login
docker tag [tag_id] [mydocker/container_backup:version]
docker push [mydocker/container_backup]

# 可保存在本地
docker save -o /home/container_backup.tar container_backup


# 恢复容器
docker load -i /home/container_backup.tar
docker images
docker run -d -p [local_port]:[container_port] container_backup
```

**17.iptables配置**
```
# 生成iptables规则保存进配置文件
$ iptables-save > /etc/sysconfig/iptables

# sample configuration for iptables service
# you can edit this manually or use system-config-firewall
# please do not ask us to add additional ports/services to this default configuration
*nat
:PREROUTING ACCEPT [27:11935]
:INPUT ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
:POSTROUTING ACCEPT [0:0]
:DOCKER - [0:0]
-A PREROUTING -m addrtype --dst-type LOCAL -j DOCKER
-A OUTPUT ! -d 127.0.0.0/8 -m addrtype --dst-type LOCAL -j DOCKER
-A POSTROUTING -s 172.17.0.0/16 ! -o docker0 -j MASQUERADE
COMMIT
# below for filter
*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
:DOCKER - [0:0]
-A FORWARD -o docker0 -j DOCKER
-A FORWARD -o docker0 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
-A FORWARD -i docker0 ! -o docker0 -j ACCEPT
-A FORWARD -i docker0 -o docker0 -j ACCEPT
-A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
-A INPUT -s 192.168.10.0/24 -p icmp -j ACCEPT
-A INPUT -s 127.0.0.1/32 -d 127.0.0.1/32 -j ACCEPT
-A INPUT -p tcp -m tcp --dport 20 -j ACCEPT
-A INPUT -p tcp -m tcp --dport 21 -j ACCEPT
-A INPUT -s 192.168.1.10/32 -p tcp -m tcp --dport 22 -j ACCEPT
-A INPUT -p tcp -m tcp --dport 80 -j ACCEPT
-A INPUT -p udp -m udp --dport 161 -j ACCEPT
-A INPUT -p tcp -m tcp --dport 443 -j ACCEPT
-A INPUT -p tcp -m tcp --dport 873 -j ACCEPT
-A INPUT -p tcp -m tcp --dport 3306 -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 11211 -j ACCEPT
-A INPUT -j REJECT
#-A INPUT -j REJECT --reject-with icmp-host-prohibited  
#-A FORWARD -j REJECT --reject-with icmp-host-prohibited  
COMMIT

# 重启服务
systemctl restart iptables.service

# 挂载目录权限问题
chcon -Rt svirt_sandbox_file_t /path/to/volume
setenforce 0
```

**18. 一些参考链接**

`https://hub.docker.com/r/sebp/elk/builds/`

`http://elk-docker.readthedocs.io/`

`https://github.com/spujadas/elk-docker/issues/135`

`https://blog.smoker.cc/docker/elk-stack-in-docker.html`

**19. 部署registry**
```
docker pull registry:latest
docker run --name registry  -p 5000:5000 -v /home/opt/docker-registry:/var/lib/registry -d registry:latest

1. 通过docker tag将该镜像标志为要推送到私有仓库
docker tag 镜像名[:标签] 镜像仓库服务器地址/命名空间/镜像发布名:发布标签

2. 运行docker push将镜像push到我们的私有仓库中
docker push 镜像仓库服务器地址/命名空间/镜像发布名:发布标签

3. 一个例子
docker tag php:7.1-fpm 127.0.0.1:5000/mydocker/php:7.1-fpm
docker push 127.0.0.1:5000/mydocker/php:7.1-fpm
然后在/home/opt/docker-registry/docker/registry/v2/repositories下看到以命名空间名mydocker命名的文件夹，上传的镜像即位于该目录下

# 删除已经push到本地仓库的镜像
1. 打开镜像的存储目录，如有-v操作打开挂载目录也可以，删除镜像文件夹
docker exec <容器名> rm -rf /var/lib/registry/docker/registry/v2/repositories/<镜像名>

2. 执行垃圾回收操作，注意2.4版本以上的registry才有此功能
docker exec registry bin/registry garbage-collect /etc/docker/registry/config.yml

# 从私有仓库pull到本地
docker pull 127.0.0.1:5000/mydocker/php:5.6-fpm
docker pull 127.0.0.1:5000/mydocker/php:7.1-fpm
docker pull 127.0.0.1:5000/mydocker/nginx:1.10.3

# 如果要查看具体版本
ls /home/opt/docker-registry/docker/registry/v2/repositories/mydocker/<镜像名>/_manifests/tags
```
