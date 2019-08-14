FROM golang:1.12.7 AS build
WORKDIR /go/src/github.com/storageos/nfs/
COPY . /go/src/github.com/storageos/nfs/
RUN make build


FROM ubuntu:bionic

LABEL maintainer="support@storageos.com"

RUN DEBIAN_FRONTEND=noninteractive \
 && apt-get update \
 && apt-get install -y software-properties-common \
 && add-apt-repository ppa:gluster/glusterfs-4.1 \
 && add-apt-repository ppa:nfs-ganesha/libntirpc-1.7 \
 && add-apt-repository ppa:nfs-ganesha/nfs-ganesha-2.7 \
 && apt-get update \
 && apt-get install -y netbase nfs-common dbus nfs-ganesha nfs-ganesha-vfs \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
 && mkdir -p /export /var/run/dbus \
 && chown messagebus:messagebus /run/dbus

COPY --from=build /go/src/github.com/storageos/nfs/build/_output/bin/nfs /nfs

# TESTING ONLY
COPY --from=build /go/src/github.com/storageos/nfs/export.conf /export.conf

# NFS port and http daemon
EXPOSE 2049 80

# Start Ganesha NFS daemon by default
CMD ["/nfs"]
