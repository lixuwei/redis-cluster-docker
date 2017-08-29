FROM lixuwei/ubuntu-rvm
MAINTAINER lixuwei <lixuweiok@gmail.com>

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -yqq \
      net-tools supervisor locales gettext-base wget && \
    apt-get clean -yqq

RUN /bin/bash -l -c 'rvm install ruby'
RUN /bin/bash -l -c 'gem install redis'

RUN apt-get install -y gcc make g++ build-essential libc6-dev tcl git supervisor

ARG redis_version=3.2.9

RUN wget -qO redis.tar.gz http://download.redis.io/releases/redis-${redis_version}.tar.gz \
    && tar xfz redis.tar.gz -C / \
    && mv /redis-$redis_version /redis

RUN (cd /redis && make)

RUN mkdir /redis-conf
RUN mkdir /redis-data

COPY ./docker-data/redis-cluster.tmpl /redis-conf/redis-cluster.tmpl
COPY ./docker-data/redis.tmpl /redis-conf/redis.tmpl

# Add supervisord configuration
COPY ./docker-data/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Add startup script
COPY ./docker-data/docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod 755 /docker-entrypoint.sh

EXPOSE 7000 7001 7002 7003 7004 7005 7006 7007

ENTRYPOINT ["/docker-entrypoint.sh", "redis-cluster"]
#CMD ["redis-cluster"]