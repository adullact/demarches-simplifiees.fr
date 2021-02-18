FROM nginx:stable-alpine

RUN mkdir -p /app/public
WORKDIR /app/public

ADD ./public /app/public
ADD ./ops/ci/release/assets/nginx.conf /etc/nginx/nginx.conf
