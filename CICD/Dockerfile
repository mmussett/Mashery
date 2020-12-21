FROM alpine:latest

RUN apk update \
 && apk add bash \
 && apk add curl \
 && apk add jq \
 && rm -rf /var/cache/apk/*

RUN mkdir /app
COPY . /app
WORKDIR /app
RUN chmod +x /app/*.sh


CMD ["/bin/bash"]