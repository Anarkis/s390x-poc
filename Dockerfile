# With OpenSUSE Leap DNF as base image
FROM registry.opensuse.org/opensuse/leap-dnf:15.3

RUN head -c 150M /dev/urandom > random-binary-file

RUN dnf -y install \
      util-linux \
      findutils \
      which \
      yajl \
      GeoIP \
      libmaxminddb0 \
      lmdb \
      wget \
      libcap-progs

RUN head -c 100M /dev/urandom > random-binary-file2
