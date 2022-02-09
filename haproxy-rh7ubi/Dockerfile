FROM registry.access.redhat.com/ubi7/ubi:latest

WORKDIR /build

RUN set -eux \
    && yum --assumeyes update \
    && yum --assumeyes install make gcc openssl-devel

RUN set -eux \
    && curl --location --output pcre2.tgz https://github.com/PhilipHazel/pcre2/releases/download/pcre2-10.39/pcre2-10.39.tar.gz \
    && mkdir pcre2 \
    && tar --extract --gunzip --strip-components=1 --file pcre2.tgz --directory pcre2 \
    && cd pcre2 \
    && ./configure --disable-shared --enable-jit \
    && make && make install

RUN set -eux \
    && curl --location --output lua.tgz http://www.lua.org/ftp/lua-5.4.4.tar.gz \
    && mkdir lua \
    && tar --extract --gunzip --strip-components=1 --file lua.tgz --directory lua \
    && make --directory lua all test \
    && make --directory lua install

RUN set -eux \
    && curl --location --output haproxy.tgz https://www.haproxy.org/download/2.4/src/haproxy-2.4.12.tar.gz \
    && mkdir haproxy \
    && tar --extract --gunzip --strip-components=1 --file haproxy.tgz --directory haproxy \
    && make --directory haproxy \
        TARGET=linux-glibc \
        USE_OPENSSL=1 \
        USE_PCRE2=1 USE_PCRE2_STATIC=1 USE_PCRE2_JIT=1 \
        USE_LUA=1 \
    && make --directory haproxy install

CMD [ "/usr/local/sbin/haproxy", "-vv" ]
