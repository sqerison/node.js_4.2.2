FROM alpine:latest

MAINTAINER Volodymyr Shynkar <volodymyr.shynkar@gmail.com>

ENV VERSION=v4.2.2 NPM_VERSION=3 CONFIG_FLAGS="--fully-static" NPM_FLAG="--without-npm" 
ENV DEL_PKGS="curl make gcc g++ binutils-gold python linux-headers paxctl libgcc libstdc++"

VOLUME ["/var/www/html/", "/opt/app/"]

RUN apk update && apk upgrade

RUN apk add --no-cache curl make gcc g++ binutils-gold python linux-headers paxctl libgcc libstdc++ && \
  curl -sSL https://nodejs.org/dist/${VERSION}/node-${VERSION}.tar.gz | tar -xz && \
  \
  cd /node-${VERSION} && \
    ./configure --prefix=/usr ${CONFIG_FLAGS} && \
    make --jobs=$(grep -c ^processor /proc/cpuinfo 2>/dev/null) && \
    make install && \
  paxctl -cm /usr/bin/node && cd / && \
  mkdir -p /opt/app/ && \
  \
  if [ -x /usr/bin/npm ]; then \
    npm install -g npm@${NPM_VERSION} && \
    find /usr/lib/node_modules/npm -name test -o -name .bin -type d | xargs rm -rf; \
  fi && \
  \
  apk del ${DEL_PKGS} && \
  rm -rf /etc/ssl /node-${VERSION} /usr/include \
    /usr/share/man /tmp/* /var/cache/apk/* /root/.npm /root/.node-gyp \
    /usr/lib/node_modules/npm/man /usr/lib/node_modules/npm/doc /usr/lib/node_modules/npm/html

#EXPOSE 8888
#EXPOSE 3000

#CMD ["node", "index.js"]