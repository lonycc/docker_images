FROM ubuntu:latest

MAINTAINER tony <tony@163.com>

ENV DEBIAN_FRONTEND noninteractive

RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo "Asia/Shanghai" > /etc/timezone
RUN rm -rf /var/lib/apt/lists/*
RUN apt-get update \
    && apt-get install -y software-properties-common nginx gunicorn supervisor \
    && add-apt-repository -y ppa:jonathonf/python-3.6 \
    && apt-get update \
    && apt-get install -y python3.6 python3-pip

RUN mkdir -p /deploy/app \
    && mkdir -p /root/.pip
COPY app /deploy/app
COPY pip.conf /root/.pip/
RUN pip3 install -r /deploy/app/requirements.txt

RUN rm /etc/nginx/sites-enabled/default
COPY flask.conf /etc/nginx/sites-available/
RUN ln -s /etc/nginx/sites-available/flask.conf /etc/nginx/sites-enabled/flask.conf
RUN echo "daemon off;" >> /etc/nginx/nginx.conf

RUN mkdir -p /var/log/supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY gunicorn.conf /etc/supervisor/conf.d/gunicorn.conf

CMD ["/usr/bin/supervisord"]
