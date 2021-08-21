source "docker" "haproxy" {
    image = "registry.access.redhat.com/ubi8/ubi:latest"
    changes = [
        "EXPOSE 80 443 8181",
        "STOPSIGNAL SIGUSR1",
        "ENTRYPOINT [ \"/docker-entrypoint.sh\" ]",
        "CMD [ \"haproxy\", \"-f\", \"/usr/local/etc/haproxy/haproxy.cfg\" ]",
        "USER haproxy",
        "LABEL haproxy-nist-0"
    ]
    export_path = "haproxy-nist-0-image.tar"
}

build {
    sources = [ "source.docker.haproxy" ]
    provisioner "shell" {
        inline = [
            "yum --assumeyes update",
            "yum --assumeyes install gcc make wget diffutils openssl-devel pcre2-devel zlib-devel",
            "mkdir -p /build/lua",
            "wget --output-document /build/lua.tgz http://www.lua.org/ftp/lua-5.4.3.tar.gz",
            "tar --extract --file /build/lua.tgz --strip-components=1 --directory /build/lua --verbose",
            "make --directory /build/lua all test",
            "wget --output-document /build/haproxy.tgz https://www.haproxy.org/download/2.4/src/haproxy-2.4.3.tar.gz",
            "tar --extract --file /build/haproxy.tgz --strip-components=1 --directory /build --verbose",
            "make --directory /build TARGET=linux-glibc USE_OPENSSL=1 USE_ZLIB=1 USE_PCRE2=1 USE_PCRE2_JIT=1 USE_LUA=1 LUA_LD_FLAGS=-Llua/src LUA_INC=lua/src",
            "make --directory /build install",
            "rm -rf /build",
            "yum --assumeyes history undo last"
        ]
    }
}