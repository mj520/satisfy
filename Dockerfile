FROM mj520/nginx-php:alpine
ADD . /data/www
RUN apk --update add --no-cache && apk upgrade --self-upgrade-only --no-cache \
    && apk add --no-cache git zip unzip openssh-client \
    && echo 'Host *' >> /etc/ssh/ssh_config \
    && echo 'StrictHostKeyChecking no' >> /etc/ssh/ssh_config
WORKDIR /data/www/
RUN composer install --no-dev && composer clearcache
ADD docker/container-files /
ENV APP_PATH=/data/www