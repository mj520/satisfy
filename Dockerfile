FROM mj520/nginx-php:alpine
ADD . /data/www
ADD docker/container-files /
RUN apk --update add --no-cache && apk upgrade --self-upgrade-only --no-cache \
    && apk add --no-cache git zip unzip openssh-client \
    && echo 'Host *' >> /etc/ssh/ssh_config \
    && echo 'StrictHostKeyChecking no' >> /etc/ssh/ssh_config \
    && cd /data/www/ \
    && composer install --no-dev \
    && composer clearcache
ENV APP_PATH=/data/www