FROM scratch
MAINTAINER ccondit@randomcoder.com
ADD stage1.tar /
ADD stage1-tools.tar /tools/
ADD stage1-packages.tar /packages/

ENV PATH /usr/local/bin:/usr/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin:/tools/bin

# tools setup
RUN [ "/tools/bin/ln", "-sfv", "/tools/bin/bash", "/bin/sh" ]

RUN \
	set +xe && \
	umask 022 && \
	ln -sfv /tools/bin/bash /usr/bin && \
	ln -sfv /tools/bin/cat  /usr/bin && \
	ln -sfv /tools/bin/echo /usr/bin && \
	ln -sfv /tools/bin/pwd /usr/bin && \
	ln -sfv /tools/bin/stty /usr/bin && \
	ln -sfv /tools/bin/perl /usr/bin && \
	ln -sfv /tools/lib/libgcc_s.so /usr/lib && \
	ln -sfv /tools/lib/libgcc_s.so.1 /usr/lib && \
	ln -sfv /tools/lib/libstdc++.so /usr/lib && \
	ln -sfv /tools/lib/libstdc++.so.6 /usr/lib && \
	sed 's/tools/usr/' /tools/lib/libstdc++.la > /usr/lib/libstdc++.la && \
	ln -sfv bash /bin/sh

# build env setup
RUN \
	set -xe && \
	umask 022 && \
	dpkg --force-depends -i /packages/openssl-bootstrap_*.deb && \
	rm -rf /packages && \
	mkdir -p /build /download /packages /control

## linux-devel
#ADD control/linux-devel /control/linux-devel
#RUN \
#	set -xe && \
#	umask 022 && \
#	LC_ALL=POSIX && \
#	TARGET_PLATFORM=$(uname -m)-uc-linux-gnu && \
#	wget -O /download/linux-4.2.1.tar.xz -c \
#		https://www.kernel.org/pub/linux/kernel/v4.x/linux-4.2.1.tar.xz && \
#	cd /build && \
#	mkdir -p destroot/usr/include && \
#	tar Pxf /download/linux-4.2.1.tar.xz && \
#	cd linux-4.2.1 && \
#	make mrproper && \
#	make INSTALL_HDR_PATH=dest headers_install && \
#	cp -rv dest/include/* /build/destroot/usr/include && \
#	make-deb \
#		/build/linux-devel-deb \
#		/build/destroot \
#		/control/linux-devel \
#		/packages/linux-devel_4.2.1-0_amd64.deb && \
#	cd / && \
#	rm -rf /build/* /download/* /control/*	

CMD ["/bin/sh"]
