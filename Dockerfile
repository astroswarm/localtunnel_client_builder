ARG ARCH

FROM astroswarm/base-$ARCH:latest

RUN apt-get -y update
RUN apt-get -y install curl xz-utils

# gpg keys listed at https://github.com/nodejs/node#release-team
RUN set -ex && \
  for key in \
    9554F04D7259F04124DE6B476D5A82AC7E37093B \
    94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
    FD3A5288F042B6850C66B31F09FE44734EB7990E \
    71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
    DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
    B9AE9905FFD7803F25714661B63B535A4C206CA9 \
    C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
    56730D5401028683275BD23C23EFEFE93C4CFFFE \
  ; do \
    gpg --keyserver pgp.mit.edu --recv-keys "$key" || \
    gpg --keyserver keyserver.pgp.com --recv-keys "$key" || \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key" ; \
  done

ENV NPM_CONFIG_LOGLEVEL info
ENV NODE_VERSION 8.1.2

ARG NODE_ARCH
RUN curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-$NODE_ARCH.tar.xz"
RUN curl -SLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc"
RUN gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc
RUN grep " node-v$NODE_VERSION-linux-$NODE_ARCH.tar.xz\$" SHASUMS256.txt | sha256sum -c -
RUN tar -xJf "node-v$NODE_VERSION-linux-$NODE_ARCH.tar.xz" -C /usr/local --strip-components=1
RUN rm "node-v$NODE_VERSION-linux-$NODE_ARCH.tar.xz" SHASUMS256.txt.asc SHASUMS256.txt
RUN ln -s /usr/local/bin/node /usr/local/bin/nodejs

RUN npm install -g localtunnel

CMD /usr/local/bin/lt --port $HTTP_PORT --local-host $HTTP_HOST
