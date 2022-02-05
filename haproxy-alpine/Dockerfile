FROM alpine:3.15

ENV HAPROXY24_URL "https://www.haproxy.org/download/2.4/src/haproxy-2.4.12.tar.gz"
ENV LUA5_URL      "http://www.lua.org/ftp/lua-5.4.4.tar.gz"
ENV OPENSSL3_URL  "https://www.openssl.org/source/openssl-3.0.1.tar.gz"
ENV PCRE2_URL     "https://github.com/PhilipHazel/pcre2/releases/download/pcre2-10.39/pcre2-10.39.tar.gz"

WORKDIR /tmp

RUN set -eux \
    && apk update \
    && apk upgrade \
    && apk add make gcc perl tar musl-dev linux-headers

COPY sha512sums.txt /tmp/
RUN set -eux \
    && wget ${HAPROXY24_URL} \
    && wget ${LUA5_URL} \
    && wget ${OPENSSL3_URL} \
    && wget ${PCRE2_URL} \
    && sha512sum -c sha512sums.txt

    # && echo "${OPENSSL3_SHA512} *openssl.tgz" | sha512sum -s \
    # && tar --extract --gunzip --strip-components=1 --file openssl.tgz --directory . \
    # && ./config enable-fips no-shared \
    # && make \
    # && make install_sw \
    # && make install_fips \
    # && rm -rf *