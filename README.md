# haproxy-in-a-can

Builds an HAProxy container image using the Red Hat 8 Universal Base Images (UBIs). The build proceeds in two stages:
1. Create a ubi container to download source packages for HAProxy and LUA, build them and
export the compiled code as a tar file.
2. Create the HAProxy image by importing the code compiled in step 1 into a ubi-minimal
container, apply additional configuration and push the resulting image out to a repository.

To build the HAProxy image, run the following command:
```
packer build -parallel-builds=1 .
```

To run the container, use something like:
```
docker run --detach --name haproxy-run --volume /path/to/config/:/usr/local/etc/haproxy/ \
           --publish 80:80 --publish 443:443 haproxy:latest
```
where /path/to/config/ is the location of your HAProxy configuration files.
