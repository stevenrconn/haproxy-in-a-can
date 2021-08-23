variable "lua_url" {
    type = string
}
variable "lua_checksum" {
    type = string
}
variable "haproxy_url" {
    type = string
}
variable "haproxy_checksum" {
    type = string
}

source "docker" "haproxy-package" {
    image = "registry.access.redhat.com/ubi8/ubi:latest"
    pull = true
    discard = true
}

build {
    sources = [ "source.docker.haproxy-package" ]
    provisioner "shell" {
        inline = [
            "set -eux",
            "yum --assumeyes update",
            "yum --assumeyes install gcc make wget diffutils openssl-devel pcre2-devel zlib-devel perl-Digest-SHA",
            "mkdir -p /build/lua",
            "wget --output-document /build/lua.tgz ${var.lua_url}",
            "echo \"${var.lua_checksum}  /build/lua.tgz\" | shasum --check --quiet -",
            "tar --extract --file /build/lua.tgz --strip-components=1 --directory /build/lua --verbose",
            "make --directory /build/lua all test",
            "wget --output-document /build/haproxy.tgz ${var.haproxy_url}",
            "echo \"${var.haproxy_checksum}  /build/haproxy.tgz\" | md5sum --check --quiet -",
            "tar --extract --file /build/haproxy.tgz --strip-components=1 --directory /build --verbose",
            "make --directory /build TARGET=linux-glibc USE_OPENSSL=1 USE_ZLIB=1 USE_PCRE2=1 USE_PCRE2_JIT=1 USE_LUA=1 LUA_LD_FLAGS=-Llua/src LUA_INC=lua/src",
            "make --directory /build install",
            "tar --create --file /tmp/haproxy-usr-local.tar --verbose /usr/local"
        ]
    }

    provisioner "file" {
        source = "/tmp/haproxy-usr-local.tar"
        destination = "haproxy-usr-local.tar"
        direction = "download"
    }

}
