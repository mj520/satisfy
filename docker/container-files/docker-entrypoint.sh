#!/bin/sh
set -e
set -u

SECRET_FILE="${APP_PATH}/config/secret.lock"
SATIS_FILE="${APP_PATH}/satis.json"

: ${ADMIN_AUTH:=false}
: ${ADMIN_USERS:="null"}

: ${REPO_NAME:="packagist/satisfy"}
: ${HOMEPAGE:="http://localhost"}

: ${GITHUB_SECRET:="null"}
: ${GITLAB_SECRET:="null"}
: ${GITLAB_AUTO_ADD_REPO:="false"}
: ${GITLAB_AUTO_ADD_REPO_TYPE:="null"}
: ${GITLAB_PREFER_SSH_URL_TYPE:="false"}
: ${GITEA_SECRET:="null"}
: ${DEVOPS_SECRET:="null"}

: ${SSH_PRIVATE_KEY:=""}

if [[ ! -e ${SECRET_FILE} ]]; then
    GENERATED_SECRET="$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 64 | head -n 1)"
    echo ${GENERATED_SECRET} > ${SECRET_FILE} 
fi

SECRET=`cat ${SECRET_FILE}`
cat > ${APP_PATH}/config/parameters.yml <<EOF
parameters:
    secret: "${SECRET}"
    satis_filename: '%kernel.project_dir%/satis.json'
    satis_log_path: '%kernel.project_dir%/var/satis'
    admin.auth: ${ADMIN_AUTH}
    admin.users: ${ADMIN_USERS}
    composer.home: '%kernel.project_dir%/.composer'
    github.secret: ${GITHUB_SECRET}
    gitlab.secret: ${GITLAB_SECRET}
    gitlab.auto_add_repo: ${GITLAB_AUTO_ADD_REPO}
    gitlab.auto_add_repo_type: ${GITLAB_AUTO_ADD_REPO_TYPE}
    gitlab.prefer_ssh_url_type: ${GITLAB_PREFER_SSH_URL_TYPE}
    gitea.secret: ${GITEA_SECRET}
    devops.secret: ${DEVOPS_SECRET}
EOF

if [[ ! -e ${SATIS_FILE} ]]; then
  cat > ${SATIS_FILE} <<EOF
{
    "name": "${REPO_NAME}",
    "homepage": "${HOMEPAGE}",
    "repositories": [
    ],
    "require-all": false,
    "providers": false,
    "require-dependencies": false,
    "require-dev-dependencies": false,
    "require-dependency-filter": false,
    "pretty-print": false,
    "archive": {
        "directory": "dist",
        "format": "zip",
        "skip-dev": false
    }
}
EOF
fi

if [[ "${SSH_PRIVATE_KEY}" != "" ]] ; then
    mkdir -p /data/www/.ssh 
    echo "${SSH_PRIVATE_KEY}" > /data/www/.ssh/id_rsa
    chmod 700 /data/www/.ssh
    chmod 600 /data/www/.ssh/id_rsa
fi

source /etc/profile
mkdir -p /data/conf/nginx /data/www /data/logs /data/tmp/php /data/tmp/nginx
chown -R www:www /data/tmp /data/logs
chown www:www -R /data/www

exec "$@"
