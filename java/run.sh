docker run --name docker-java -p 8080:8080 -d -v /home/opt/docker-java/webapps:/usr/local/tomcat8/webapps -v /home/opt/docker-java/logs:/usr/local/tomcat8/logs -v /home/opt/docker-java/conf:/usr/local/tomcat8/conf mydocker/java:8.0