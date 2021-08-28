# haproxy-in-a-can

Builds an HAProxy container image using the Red Hat 8 Universal Base Images (UBIs). This repo contains both a Dockerfile
and a Packer build script.

## Building the container image using Docker
To build the HAProxy container image using Docker, use the following command:
```
docker build --tag haproxy-ubi:<version> .
```
where `<version>` is the release number of the HAProxy build.

### Docker build arguments
You may set the following build arguments using the `--build-args` option:
|Variable|Definition|
|-----|-----|
|`haproxy_version_major`|The first two parts of the HAProxy version (default 2.4)|
|`haproxy_version_minor`|The last part of the HAProxy version (default 3)|
|`lua_version`|LUA version (default 5.4.3)|

## Building and pushing the container image using Packer
The Packer build proceeds in two stages:
1. Create a ubi container to download source packages for HAProxy and LUA, build them and
export the compiled code as a tar file.
2. Create the HAProxy image by importing the code compiled in step 1 into a ubi-minimal
container, apply additional configuration and push the resulting image out to a repository.

To build and push the HAProxy image using Packer, run the following command:
```
packer build -parallel-builds=1 .
```
### Packer build configuration
The file `config.auto.pkrvars.hcl` contains several variables used to configure the Packer build
process:

|Variable|Definition|
|-----|-----|
|`lua_url`|URL of the LUA TAR archive|
|`lua_checksum`|SHA1 checksum of LUA TAR archive|
|`haproxy_url`|URL of the HAProxy TAR archive|
|`haproxy_checksum`|MD5 checksum of HAProxy tar archive|
|`haproxy_version`|used as the tag for the image|
|`repository`|repository/name of the image|

## Running the container
To run the container, use something like:
```
docker run --detach --name haproxy-run --volume /path/to/config/:/usr/local/etc/haproxy/ \
           --publish 80:80 --publish 443:443 haproxy:latest
```
where /path/to/config/ is the location of your HAProxy configuration files.