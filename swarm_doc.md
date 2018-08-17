# [搭建一个swarm cluster](http://www.cnblogs.com/atuotuo/p/6260591.html)

三台机器

node1: 172.23.130.202

node2: 172.23.130.203

node3: 172.23.130.204

三台机器都开放2377/tcp(cluster管理端口)、7946/udp(节点间通信)、4789/udp(overlay网络端口)

node1上运行`docker swarm init`去启动一台cluster manager节点， 然后在node2和node3上运行`docker swarm join --token SWMTKN-1-2amntmuwfkj3y9qn1623h33b4dc3mt2s5cxehlzh3nr40016bb-axvglr7f7a92rgvir9ihruvx4 172.23.130.202:2377`，就能将节点加入到cluster。

`docker node ls`查看所有swarm节点运行状态。

创建好cluster后，用`docker service`批量对cluster内的容器进行管理。



## master

`10.2.100.56`

## worker

`10.2.100.82` 和 `10.2.100.195`

`docker swarm init --listen-addr 10.2.100.56:2377 --advertise-addr 10.2.100.56` #初始化

`docker swarm join \
    --token SWMTKN-1-1quih2h3h3yoscbn8pyetoxhjtlen387pthkxf0vcna1fyi02y-3cxdjxx4kzmru15ehbktm1qox \
    10.2.100.56:2377` #添加worker到cluster
    
`docker swarm join-token worker` #查看添加成为worker的方法

`docker node ls` #查看节点状态

`docker node ps` #查看节点运行信息

`docker node inspect self`  #查看一个node的状态信息

`docker swarm leave` #在worker上执行, 离开cluster

`docker node rm --force node_id` #在master上执行, 删除指定worker

`docker service create --replicas 1 --name helloworld alpine ping docker.com`

`docker service inspect --pretty helloworld`

`docker service ls`

`docker service ps <service_id|service_name>` #查看服务在哪个节点上运行

`docker service scale helloworld=5` #动态扩展服务, 运行5个helloworld实例

`docker service rm helloworld` #删除集群中的服务

`docker service update --image tomcat:8.6.0 tomcat-service tomcat-service` #更新集群中的服务

`docker service update <SERVICE-ID|service_name>` #重启一个暂停更新的服务

`docker node update --availability drain <Node-ID>` #停用Swarm集群中的服务节点

`docker node inspect --pretty <node_id>`

`docker node update --availability active <NODE-ID>` #启用Swarm集群中的服务节点


[基于docker machine创建的集群](http://www.jianshu.com/p/9eb9995884a5)

`curl -L https://github.com/docker/machine/releases/download/v0.11.0/docker-machine-`uname -s`-`uname -m` >/tmp/docker-machine &&
    chmod +x /tmp/docker-machine &&
    sudo cp /tmp/docker-machine /usr/local/bin/docker-machine` #下载并安装docker-machine
    
`docker-machine create --driver virtualbox manager1` #创建一个虚拟机作为manager节点

`docker-machine env manager1` #查看虚拟机环境变量

`docker-machine create --driver virtualbox worker1` #创建一个worker节点

`docker-machine ls` #查看

` docker-machine ssh manager1 docker swarm init ...` #docker-machine ssh manager1只是连接虚拟机, 后面的命令同swarm

`docker network ls` #查看网络列表

`docker network create --driver overlay swarm_test` #创建一个名为swarm_test的overlay网络

`docker service create --replicas 2 --name helloworld --network=swarm_test nginx:alpine` #部署服务使用swarm_test跨主机网络

`docker-machine ssh worker2 docker kill <service_name>` #杀死worker2节点上的服务

`docker-machine scp docker-compose.yml myvm1:~`

`docker-machine ssh master1 docker stack deploy -c docker-compose.yml [service_name]`

`docker-machine ssh myvm1 "docker stack ps [service_name]"`

# docker四种网络模式

> host模式, docker使用的网络和宿主机一样, 自动映射

`docker run --net-host`

> container模式, 多个容器使用共同的网络, 看到的ip一样

`--net=container:container_id/container_name`

> none模式, 不会分配局域网IP

`--net=none`

> bridge模式, 默认模式, 会给每个容器分配一个独立的network namespace; 每次容器重启ip则发生变化

`--net=bridge`

## 创建自定义网络

`docker network create --subnet=172.18.0.0/16 mynetwork`

`docker network ls`

`docker run -itd --name networkTest1 --net mynetwork --ip 172.18.0.2 centos:latest /bin/bash` #固定容器ip
