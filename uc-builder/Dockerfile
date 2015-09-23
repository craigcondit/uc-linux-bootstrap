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
	apt-get install --no-install-recommends -y -q build-essential curl gawk zlib1g-dev && \
	rm -rf /var/cache/apt && \
	mkdir -p /download /build /build/root

# zlib
RUN \
	set -xe && \
	curl -ksSL http://www.zlib.net/zlib-1.2.8.tar.xz > \
		/download/zlib-1.2.8.tar.xz && \
	cd /build && \
	tar xf /download/zlib-1.2.8.tar.xz && \
	cd /build/zlib-1.2.8 && \
	echo "Configuring zlib..." >&2 && \
	./configure --prefix=/usr --shared --libdir=/lib && \
	make && \
	mkdir -p /build/zlib-root && \
	make DESTDIR=/build/zlib-root install && \
	rm -rf \
		/build/zlib-root/usr/share \
		/build/zlib-root/usr/include \
		/build/zlib-root/lib/pkgconfig && \
	rm -f /build/zlib-root/lib/*.a && \
	strip /build/zlib-root/lib/* && \
	rm -f /build/zlib-root/lib/libz.so && \
	mkdir -p /build/zlib-root/usr/lib && \
	ln -sfv ../../lib/libz.so.1.2.3 /build/zlib-root/usr/lib/libz.so && \
	cp -a /build/zlib-root/* /build/root/ && \
	cd /build && \
	rm -rf /build/zlib-1.2.8 /build/zlib-root

# glibc
RUN \
	set -xe && \
	curl -ksSL https://www.kernel.org/pub/linux/kernel/v4.x/linux-4.2.1.tar.xz >  \
		/download/linux-4.2.1.tar.xz && \
	cd /build && \
	tar Pxf /download/linux-4.2.1.tar.xz && \
	echo "Building linux headers..." >&2 && \
	cd /build/linux-4.2.1 && \
	make mrproper && \
	make INSTALL_HDR_PATH=dest headers_install && \
	mkdir -p /build/linux-include && \
	cp -r dest/include/* /build/linux-include && \
	cd /build && \
	rm -rf /build/linux-4.2.1 && \
	echo "Downloading glibc..." >&2 && \
	curl -ksSL http://ftp.gnu.org/gnu/glibc/glibc-2.22.tar.xz > \
		/download/glibc-2.22.tar.xz && \
	echo "Downloading glibc patches..." >&2 && \
	curl -ksSL http://www.linuxfromscratch.org/patches/lfs/systemd/glibc-2.22-fhs-1.patch > \
		/download/glibc-2.22-fhs-1.patch && \
	curl -ksSL http://www.linuxfromscratch.org/patches/lfs/systemd/glibc-2.22-upstream_i386_fix-1.patch > \
		/download/glibc-2.22-upstream_i386_fix-1.patch && \
	cd /build && \
	echo "Unpacking glibc..." >&2 && \
	tar xf /download/glibc-2.22.tar.xz && \
	cd /build/glibc-2.22 && \
	echo "Patching glibc..." >&2 && \
	patch -Np1 -i /download/glibc-2.22-fhs-1.patch && \
	patch -Np1 -i /download/glibc-2.22-upstream_i386_fix-1.patch && \
	mkdir -p /build/glibc-build && \
	cd /build/glibc-build && \
	echo "Configuring glibc..." >&2 && \
	/build/glibc-2.22/configure --prefix=/usr --disable-profile --enable-kernel=2.6.32 && \
	echo "Building glibc..." >&2 && \
	MAKE="make -j4" make && \
	echo "Installing glibc..." >&2 && \
	mkdir -p /build/glibc-root/etc && \
	touch /build/glibc-root/etc/ld.so.conf && \
	echo 'hosts: files mdns4_minimal [NOTFOUND=return] dns mdns4' \
		> /build/glibc-root/etc/nsswitch.conf && \
	make install_root=/build/glibc-root install && \
	mkdir -p /build/glibc-root/usr/lib/locale && \
	I18NPATH=/build/glibc-2.22/localedata \
		locale/localedef --alias-file=../glibc-2.22/intl/locale.alias \
		-i ../glibc-2.22/localedata/locales/en_US -c \
		-f ../glibc-2.22/localedata/charmaps/ISO-8859-1 \
		--prefix=/build/glibc-root en_US && \
	I18NPATH=/build/glibc-2.22/localedata \
		locale/localedef --alias-file=../glibc-2.22/intl/locale.alias \
		-i ../glibc-2.22/localedata/locales/en_US -c \
		-f ../glibc-2.22/localedata/charmaps/UTF-8 \
		--prefix=/build/glibc-root en_US && \
	rm -f /build/glibc-root/etc/rpc && \
	rm -rf /build/glibc-root/var && \
	rm -f /build/glibc-root/sbin/sln && \
	rm -rf /build/glibc-root/usr/include && \
	rm -rf /build/glibc-root/usr/share/i18n && \
	find /build/glibc-root -name "*.a" -delete && \
	(strip \
		/build/glibc-root/sbin/* \
		/build/glibc-root/lib64/* \
		/build/glibc-root/usr/bin/* \
		/build/glibc-root/usr/sbin/* \
		/build/glibc-root/usr/lib64/* \
		/build/glibc-root/usr/lib64/*/* || /bin/true) && \
	cp -a /build/glibc-root/* /build/root/ && \
        cd /build && \
        rm -rf /build/glibc-2.22 /build/glibc-build /build/glibc-root /build/linux-include

# busybox
RUN \
	set -xe && \
        curl -ksSL http://www.busybox.net/downloads/busybox-1.23.2.tar.bz2 > \
                /download/busybox-1.23.2.tar.bz2 && \
	cd /build && \
	tar xf /download/busybox-1.23.2.tar.bz2 && \
	cd busybox-1.23.2 && \
	confs=' \
		CONFIG_AR \
		CONFIG_FEATURE_AR_LONG_FILENAMES \
		CONFIG_FEATURE_AR_CREATE \
		CONFIG_DPKG \
		CONFIG_DPKG_DEB' && \
	make defconfig && \
	for conf in $confs; do \
		sed -i "s!^# $conf is not set\$!$conf=y!" .config; \
		grep -q "^$conf=y" .config || echo "$conf=y" >> .config; \
	done && \
	make oldconfig && \
	for conf in $confs; do grep -q "^$conf=y" .config; done && \
	MAKE="make -j4" make && \
	make install && \
	rm -f _install/linuxrc && \
	cp -an _install/* /build/root/ && \
	chmod 4755 /build/root/bin/busybox && \
	cd /build && \
	rm -rf /build/busybox-1.23.2

# openssl
RUN \
	set -xe && \
	curl -ksSL https://www.openssl.org/source/openssl-1.0.2d.tar.gz > \
		/download/openssl-1.0.2d.tar.gz && \
	cd /build && \
	tar xf /download/openssl-1.0.2d.tar.gz && \
	cd openssl-1.0.2d && \
	./config --prefix=/usr --openssldir=/etc/ssl --libdir=lib shared zlib-dynamic && \
	sed -i 's# libcrypto.a##;s# libssl.a##' Makefile && \
	make && \
	mkdir -p /build/openssl-root && \
	make INSTALL_PREFIX=/build/openssl-root install && \
	rm -rf /build/openssl-root/etc/ssl/man && \
	rm -rf /build/openssl-root/usr/include && \
	rm -rf /build/openssl-root/usr/lib/pkgconfig && \
	(strip \
		/build/openssl-root/usr/bin/* \
		/build/openssl-root/usr/lib/* \
		/build/openssl-root/usr/inb/*.* || /bin/true) && \
	cp -an /build/openssl-root/* /build/root/ && \
        cd /build && \
        rm -rf /build/openssl-1.0.2d /build/openssl-root
	
# filesystem mods
ADD filesystem /build/root
RUN \
	set -xe && \
	install -d -m 1777 /build/root/tmp && \
	mkdir -p /build/root/var && \
	ln -sf /tmp /build/root/var/tmp && \
	mkdir -p /build/root/root && \
	mkdir -p /build/root/home && \
	chmod 644 /build/root/etc/passwd && \
	chmod 640 /build/root/etc/shadow && \
	chmod 644 /build/root/etc/group && \
	chmod 640 /build/root/etc/gshadow && \
	mkdir -p /build/root/var/lib/dpkg/info && \
	touch /build/root/var/lib/dpkg/status && \
	echo "/lib64" > /build/root/etc/ld.so.conf && \
	echo "/lib" >> /build/root/etc/ld.so.conf && \
	echo "/usr/lib64" >> /build/root/etc/ld.so.conf && \
	echo "/usr/lib" >> /build/root/etc/ld.so.conf && \
	chroot /build/root /sbin/ldconfig

# next steps build packages to make the system self-hosting

ADD binutils-bootstrap-assets /build/binutils-bootstrap-assets
RUN \
	set -xe && \
        curl -ksSL http://ftp.gnu.org/gnu/binutils/binutils-2.25.1.tar.bz2 > \
                /download/binutils-2.25.1.tar.bz2 && \
	cd /build && \
	tar xf /download/binutils-2.25.1.tar.bz2 && \
	mkdir binutils-build && \
	cd binutils-build && \
	../binutils-2.25.1/configure \
		--prefix=/usr --disable-nls --disable-werror \
		--with-lib-path=/usr/lib --with-sysroot && \
	MAKE="make -j4" make && \
	mkdir -p /build/deb && \
	cd /build/binutils-build && \
	mkdir -p /build/binutils-root && \
	make DESTDIR=/build/binutils-root install && \
	rm -f /build/binutils-root/usr/bin/strings && \
	rm -f /build/binutils-root/usr/bin/ar && \
	strip /build/binutils-root/usr/bin/* && \
	strip /build/binutils-root/usr/x86_64-unknown-linux-gnu/bin/* && \
	rm -rf /build/binutils-root/usr/share && \
	mkdir -p /build/binutils-deb/control && \
	cd /build/binutils-root && \
	find -type f | xargs md5sum | sed 's/  \.\//  /' > /build/binutils-deb/control/md5sums && \
	cp /build/binutils-bootstrap-assets/control /build/binutils-deb/control/control && \
	cd /build/binutils-deb/control && \
	tar --hard-dereference --portability -zcf ../control.tar.gz . && \
	cd /build/binutils-root && \
	tar --hard-dereference --portability -zcf /build/binutils-deb/data.tar.gz . && \
	cd /build/binutils-deb && \
	echo "2.0" > debian-binary && \
	ar rc /build/deb/binutils-bootstrap_2.25.1-0+uc0_amd64.deb \
		debian-binary control.tar.gz data.tar.gz && \
	rm -rf /build/binutils-bootstrap-assets /build/binutils-2.25.1 /build/binutils-root \
		/build/binutils-deb

CMD ["/bin/bash"]	
	
