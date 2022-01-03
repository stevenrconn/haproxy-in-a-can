locals {
    haproxy_url = "https://www.haproxy.org/download/${var.haproxy_release_major}/src/haproxy-${var.haproxy_release_major}.${var.haproxy_release_minor}.tar.gz"
    lua_url     = "http://www.lua.org/ftp/lua-${var.lua_release}.tar.gz"
    openssl_url = "https://www.openssl.org/source/openssl-${var.openssl_release}.tar.gz"
    pcre2_url   = "https://github.com/PhilipHazel/pcre2/releases/download/pcre2-${var.pcre2_release}/pcre2-${var.pcre2_release}.tar.gz"
}

source "docker" "haproxy-package" {
    image = "${var.base_image_registry}:${var.base_image_tag}"
    pull = true
    discard = true
}

build {
    sources = [ "source.docker.haproxy-package" ]

    provisioner "file" {
        source = "ssl_sock.c.patch"
        destination = "/tmp/"
    }

    provisioner "shell" {
        inline = [
            "set -eux",
            "yum --assumeyes update",
            "yum --assumeyes install gcc make perl diffutils patch perl-Digest-SHA curl",

            "curl --output /tmp/haproxy.tgz --location ${local.haproxy_url}",
            "echo \"${var.haproxy_sha512} */tmp/haproxy.tgz\" | shasum --check --algorithm 512 -",
            "curl --output /tmp/lua.tgz --location ${local.lua_url}",
            "echo \"${var.lua_sha512} */tmp/lua.tgz\" | shasum --check --algorithm 512 -",
            "curl --output /tmp/openssl.tgz ${local.openssl_url}",
            "echo \"${var.openssl_sha512} */tmp/openssl.tgz\" | shasum --check --algorithm 512 -",
            "curl --output /tmp/pcre2.tgz --location ${local.pcre2_url}",
            "echo \"${var.pcre2_sha512} */tmp/pcre2.tgz\" | shasum --check --algorithm 512 -",

            "mkdir /build",
            "cd /build",

            "tar --extract --gunzip --strip-components=1 --file /tmp/lua.tgz --directory /build",
            "make all test && make install",
            "rm --recursive --force *",

            "tar --extract --gunzip --strip-components=1 --file /tmp/openssl.tgz --directory /build",
            "./config no-shared enable-fips",
            "make && make test && make install_sw && make install_fips",
            "rm --recursive --force *",

            "tar --extract --gunzip --strip-components=1 --file /tmp/pcre2.tgz --directory /build",
            "./configure --enable-static --enable-jit",
            "make && make check && make install",
            "rm --recursive --force *",

            "tar --extract --gunzip --strip-components=1 --file /tmp/haproxy.tgz --directory /build",
            "patch src/ssl_sock.c /tmp/ssl_sock.c.patch",
            "make TARGET=linux-glibc \\",
            "     USE_OPENSSL=1 SSL_INC=/usr/local/include SSL_LIB=/usr/local/lib64 \\",
            "     USE_LUA=1 LUA_INC=/usr/local/include LUA_LIB=/usr/local/lib \\",
            "     USE_PCRE2=1 USE_STATIC_PCRE2=1 USE_PCRE2_JIT=1 PCRE2_INC=/usr/local/include PCRE2_LIB=/usr/local/lib",
            "make install",

            "tar --create --gzip --file /tmp/haproxy.tar.gz /usr/local"
        ]
    }

    provisioner "file" {
        source = "/tmp/haproxy.tar.gz"
        destination = "${path.root}/"
        direction = "download"
    }
}
