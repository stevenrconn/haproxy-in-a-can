source "docker" "haproxy-image" {
    image = "${var.base_image_registry}-minimal:${var.base_image_tag}"
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
            "${path.root}/haproxy.cfg",
            "${path.root}/pub1.pem",
            "${path.root}/docker-entrypoint.sh"
        ]
        destination = "/tmp/"
    }

    provisioner "file" {
        source = "${path.root}/haproxy.tar.gz"
        destination = "/tmp/"
        generated = true
    }

    provisioner "shell" {
        inline = [
            "set -eux",
            "microdnf update",
            "microdnf install shadow-utils",

            "groupadd haproxy",
            "useradd --gid haproxy haproxy",

            "tar --extract --gunzip --file /tmp/haproxy.tar.gz --directory /",
            "cp /tmp/docker-entrypoint.sh /",
            "chmod +x /docker-entrypoint.sh",
            "cp /tmp/{haproxy.cfg,pub1.pem,haproxy.cfg} /usr/local/etc/haproxy/",
            "rm /tmp/{haproxy.tar.gz,docker-entrypoint.sh,pub1.pem,haproxy.cfg}"
        ]
    }

    post-processors {
        post-processor "docker-tag" {
            repository = "${var.haproxy_image_registry}"
            tags = [ "${var.haproxy_image_tag}", "latest" ]
        } 
        post-processor "docker-push" {}
    }   
}