FROM debian:jessie
MAINTAINER ccondit@randomcoder.com

# setup
RUN \
	set -xe && \
	echo "deb http://ftp.us.debian.org/debian/ jessie main" \
		> /etc/apt/sources.list && \
        echo "deb http://security.debian.org/ jessie/updates main" \
		>> /etc/apt/sources.list && \
        echo "deb http://ftp.us.debian.org/debian/ jessie-updates main" \
		>> /etc/apt/sources.list && \
	apt-get update && \
	apt-get install --no-install-recommends -y -q build-essential \
		curl gawk zlib1g-dev file flex bison m4 texinfo xz-utils && \
	rm -rf /var/cache/apt && \
	mkdir -p /download /build /build/root /build/deb /build/control

# base-files
ADD base-files /build/base-files-root
ADD control/base-files /build/control/base-files
RUN \
	set -xe && \
	umask 022 && \
	cd /build/base-files-root && \
	install -d -m 755 usr/lib && \
	ln -sf usr/lib lib && \
	ln -sf lib usr/lib64 && \
	ln -sf usr/lib lib64 && \
	chmod 755 usr usr/lib usr/bin && \
	chmod 644 usr/lib/os-release && \
	chmod 755 usr/bin/make-deb && \
	install -d -m 755 etc var home && \
	install -d -m 755 var/lib/dpkg/info && \
	install -d -m 700 root && \
	install -d -m 1777 tmp && \
	chmod 644 etc/passwd && \
	chmod 640 etc/shadow && \
	chmod 644 etc/group && \
	chmod 640 etc/gshadow && \
	echo 'hosts: files mdns4_minimal [NOTFOUND=return] dns mdns4' \
                > etc/nsswitch.conf && \
	chmod 644 etc/nsswitch.conf && \
	ln -sf /tmp var/tmp && \
	install -d -m 777 var/lib var/lib/dpkg var/lib/dpkg/info && \
	touch var/lib/dpkg/status && \
	echo "/lib64" > etc/ld.so.conf && \
	echo "/lib" >> etc/ld.so.conf && \
	echo "/usr/lib64" >> etc/ld.so.conf && \
	echo "/usr/lib" >> etc/ld.so.conf && \
	find -type d | sort > /build/files-base-files && \
	echo "" >> /build/files-base-files && \
	find -not -type d | sort >> /build/files-base-files && \
	usr/bin/make-deb \
		/build/base-files-deb \
		/build/base-files-root \
		/build/control/base-files \
		/build/deb/base-files_0.0.1-0_all.deb && \
	dpkg-deb -x /build/deb/base-files_0.0.1-0_all.deb /build/root && \
	rm -rf /build/base-files-root /build/control/base-files

# cross toolchain

# binutils (stage 1)
RUN \
	set -xe && \
	umask 022 && \
	TARGET_PLATFORM=$(uname -m)-uc-linux-gnu && \
	PATH=/tools/bin:/bin:/usr/bin && \
	curl -ksSL http://ftp.gnu.org/gnu/binutils/binutils-2.25.1.tar.bz2 > \
		/download/binutils-2.25.1.tar.bz2 && \
	cd /build && \
	tar xf /download/binutils-2.25.1.tar.bz2 && \
	mkdir binutils-build && \
	cd binutils-build && \
	../binutils-2.25.1/configure \
		--prefix=/tools --with-sysroot=/tools --with-lib-path=/tools/lib \
		--target="$TARGET_PLATFORM" --disable-nls --disable-werror && \
	MAKE="make -j4" make && \
	mkdir -p /tools/lib && \
	ln -sv lib /tools/lib64 && \
	make install && \
	cd /build && \
	rm -rf binutils-2.25.1 binutils-build


# gcc (stage 1)


CMD ["/bin/bash"]
