FROM scratch
MAINTAINER ccondit@randomcoder.com
ADD stage2.tar.xz /
ADD Manifest /Manifest

ENV PATH /usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin

RUN \
	set -x && \
	umask 022 && \
	LC_ALL=POSIX && \
	mkdir -p /download /packages /build && \
	cd /download && \
	for pkg in $(cat /Manifest) ; do wget -O "$(echo $pkg | sed 's@.*/@@')" "${pkg}" ; done && \
	for pkg in $(cat /Manifest) ; do dpkg --force-depends -i "$(echo $pkg | sed 's@.*/@@')" ; done

CMD ["/bin/sh"]
