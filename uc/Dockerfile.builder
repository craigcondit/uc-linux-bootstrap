FROM debian:jessie
MAINTAINER ccondit@randomcoder.com

RUN \
	echo "deb http://ftp.us.debian.org/debian/ jessie main" \
		> /etc/apt/sources.list && \
        echo "deb http://security.debian.org/ jessie/updates main" \
		>> /etc/apt/sources.list && \
        echo "deb http://ftp.us.debian.org/debian/ jessie-updates main" \
		>> /etc/apt/sources.list && \
	apt-get update && \
	apt-get install --no-install-recommends -y -q build-essential curl gawk && \
	rm -rf /var/cache/apt && \
	mkdir -p /download /build /build/root && \
	echo "Downloading zlib..." >&2 && \
	curl -ksSL http://www.zlib.net/zlib-1.2.8.tar.xz > \
		/download/zlib-1.2.8.tar.xz && \
	cd /build && \
	echo "Unpacking zlib..." >&2 && \
	tar xf /download/zlib-1.2.8.tar.xz && \
	cd /build/zlib-1.2.8 && \
	echo "Configuring zlib..." >&2 && \
	./configure --prefix=/usr --shared --libdir=/lib && \
	echo "Building zlib..." >&2 && \
	make && \
	echo "Installing zlib..." >&2 && \
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
	rm -rf /build/zlib-1.2.8 /build/zlib-root && \
	echo "Downloading linux..." >&2 && \
	curl -ksSL https://www.kernel.org/pub/linux/kernel/v4.x/linux-4.2.1.tar.xz >  \
		/download/linux-4.2.1.tar.xz && \
	cd /build && \
	echo "Unpacking linux..." >&2 && \
	tar Pxf /download/linux-4.2.1.tar.xz && \
	echo "Building linux headers..." >&2 && \
	cd /build/linux-4.2.1 && \
	make mrproper && \
	make INSTALL_HDR_PATH=dest headers_install && \
	echo "Installing linux headers..." >&2 && \
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
        rm -rf /build/glibc-2.22 /build/glibc-build /build/glibc-root /build/linux-include && \
	echo "Downloading busybox..." >&2 && \
        curl -ksSL http://www.busybox.net/downloads/busybox-1.23.2.tar.bz2 > \
                /download/busybox-1.23.2.tar.bz2 && \
	cd /build && \
	echo "Unpacking busybox..." >&2 && \
	tar xvf /download/busybox-1.23.2.tar.bz2 && \
	cd busybox-1.23.2 && \
	echo "Configuring busybox..." >&2 && \
	make defconfig && \
	echo "Building busybox..." >&2 && \
	MAKE="make -j4" make && \
	echo "Installing busybox..." >&2 && \
	make install && \
	rm -f _install/linuxrc && \
	cp -an _install/* /build/root/ && \
	chmod 4755 /build/root/bin/busybox && \
	cd /build && \
	rm -rf /build/busybox-1.23.2

CMD ["/bin/bash"]	
	
