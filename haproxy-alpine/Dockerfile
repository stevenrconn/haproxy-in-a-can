FROM alpine:3.15

ENV HAPROXY24_URL "https://www.haproxy.org/download/2.4/src/haproxy-2.4.12.tar.gz"
ENV LUA5_URL      "http://www.lua.org/ftp/lua-5.4.4.tar.gz"
ENV OPENSSL3_URL  "https://www.openssl.org/source/openssl-3.0.1.tar.gz"
ENV PCRE2_URL     "https://github.com/PhilipHazel/pcre2/releases/download/pcre2-10.39/pcre2-10.39.tar.gz"

WORKDIR /tmp

RUN set -eux \
    && apk update \
    && apk upgrade \
    && apk add make gcc perl patch musl-dev linux-headers

COPY sha512sums.txt ssl_sock.c.patch /tmp/
RUN set -eux \
    && wget ${HAPROXY24_URL} \
    && wget ${LUA5_URL} \
    && wget ${OPENSSL3_URL} \
    && wget ${PCRE2_URL} \
    && sha512sum sha512sums.txt

RUN set -eux \
    && tar -xzvf lua* \
    && cd lua* \
    && make all test \
    && make install

RUN set -eux \
    && tar -xzvf openssl* \
    && cd openssl* \
    && ./config enable-fips no-shared \
    && make \
    && make install_sw \
    && make install_fips

RUN set -eux \
    && tar -xzvf pcre2* \
    && cd pcre2* \
    && ./configure --disable-shared --enable-jit \
    && make \
    && make install

RUN set -eux \
    && tar -xzf haproxy* \
    && cd haproxy* \
    && patch src/ssl_sock.c ../ssl_sock.c.patch \
    && make TARGET=linux-musl \
            USE_LUA=1 \
            USE_PCRE2=1 USE_PCRE2_STATIC=1 USE_PCRE2_JIT=1 \
            USE_OPENSSL=1 \
    && make install
