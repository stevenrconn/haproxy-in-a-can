FROM registry.access.redhat.com/ubi8/ubi:latest AS BUILD

WORKDIR /build

RUN set -ex \
    && yum --assumeyes update \
    && yum --assumeyes install gcc make wget diffutils openssl-devel zlib-devel pcre-devel \
    && groupadd haproxy \
    && useradd --gid haproxy haproxy

RUN set -ex \
    && wget --output-document lua.tgz http://www.lua.org/ftp/lua-5.4.3.tar.gz \
    && wget --output-document haproxy.tgz https://www.haproxy.org/download/2.4/src/haproxy-2.4.3.tar.gz

RUN set -ex \
    && mkdir lua \
    && tar --extract --file lua.tgz --strip-components=1 --directory lua --verbose \
    && cd lua \
    && make all test \
    && cd ..

RUN set -ex \
    && tar --extract --file haproxy.tgz --strip-components=1 --verbose \
    && make TARGET=linux-glibc \
            USE_OPENSSL=1 \
            USE_ZLIB=1 \
            USE_PCRE=1 \
            USE_LUA=1 LUA_LD_FLAGS=-Llua/src LUA_INC=lua/src \
    && make install 

FROM registry.access.redhat.com/ubi8/ubi-minimal AS IMAGE
COPY --from=BUILD /usr/local /usr/local
COPY docker-entrypoint.sh /usr/local/bin
COPY haproxy.cfg /usr/local/etc/haproxy/haproxy.cfg
RUN set -ex \
    && chmod +x /usr/local/bin/docker-entrypoint.sh
STOPSIGNAL SIGUSR1
ENTRYPOINT [ "docker-entrypoint.sh" ]
CMD [ "haproxy", "-f", "/usr/local/etc/haproxy/haproxy.cfg" ] 