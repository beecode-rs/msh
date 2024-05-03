FROM node:20.12.2-alpine3.19

ENV ROOT_HOME=/root \
    HOME=/home/node \
    PATH="/home/node/.npm-global/bin:${PATH}" \
    NPM_CONFIG_PREFIX=/home/node/.npm-global \
    NPM_CONFIG_LOGLEVEL=warn \
    APP_PATH=/usr/app

RUN apk add -qU --no-cache git curl nano && \
    curl -s -o /usr/bin/codecov https://uploader.codecov.io/latest/alpine/codecov && \
    chmod +x /usr/bin/codecov

USER node

RUN npm set progress=false && \
    npm config set sign-git-tag false && \
    npm config set git-tag-version false && \
    npm cache clear --force && \
    npm install -g npm@9.6.1

WORKDIR $APP_PATH
