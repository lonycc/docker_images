FROM ubuntu:latest

MAINTAINER tony <tony@163.com>

ENV DEBIAN_FRONTEND noninteractive

RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo "Asia/Shanghai" > /etc/timezone
RUN rm -rf /var/lib/apt/lists/*
RUN apt-get update
RUN apt-get install -y python python-pip python-virtualenv nginx gunicorn supervisor

RUN mkdir -p /deploy/app
COPY app /deploy/app
RUN pip install -r /deploy/app/requirements.txt

RUN rm /etc/nginx/sites-enabled/default
COPY flask.conf /etc/nginx/sites-available/
RUN ln -s /etc/nginx/sites-available/flask.conf /etc/nginx/sites-enabled/flask.conf
RUN echo "daemon off;" >> /etc/nginx/nginx.conf

RUN mkdir -p /var/log/supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY gunicorn.conf /etc/supervisor/conf.d/gunicorn.conf

CMD ["/usr/bin/supervisord"]
