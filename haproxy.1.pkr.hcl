variable "haproxy_version" {
    type = string
}
variable "repository" {
    type = string
}

source "docker" "haproxy-image" {
    image = "registry.access.redhat.com/ubi8/ubi-minimal:latest"
    pull = true
    commit = true
    changes = [
        "EXPOSE 80 443 8181",
        "ENTRYPOINT [ \"/docker-entrypoint.sh\" ]",
        "CMD [ \"haproxy\", \"-f\", \"/usr/local/etc/haproxy/haproxy.cfg\" ]",
    ]
    run_command = [ 
        "--entrypoint=/bin/sh",
        "--stop-signal=SIGUSR1", 
        "-d", "-i", "-t", "--", 
        "{{.Image}}"
    ]
}

build {
    sources = [ "source.docker.haproxy-image" ]
    provisioner "file" {
        sources = [
            "haproxy.cfg",
            "pub1.pem",
            "docker-entrypoint.sh",
            "haproxy-usr-local.tar"
        ]
        destination = "/tmp/"
    }
    provisioner "shell" {
        inline = [
            "set -eux",
            "microdnf update",
            "microdnf install shadow-utils tar",
            "groupadd haproxy",
            "useradd --gid haproxy haproxy",
            "tar --extract --file /tmp/haproxy-usr-local.tar --directory /",
            "mv /tmp/docker-entrypoint.sh /",
            "chmod +x /docker-entrypoint.sh",
            "mkdir --parents /usr/local/etc/haproxy",
            "mv /tmp/haproxy.cfg /tmp/pub1.pem /usr/local/etc/haproxy",
        ]
    }
    post-processors {
        post-processor "docker-tag" {
            repository = "${var.repository}"
            tags = [ "${var.haproxy_version}", "latest" ]
        } 
        post-processor "docker-push" {}
    }   
}