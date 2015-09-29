FROM scratch
MAINTAINER ccondit@randomcoder.com
ADD stage1.tar.xz /
ADD stage1-tools.tar.xz /tools/
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
	ln -sfv bash /bin/sh && \
	ln -sfv /tools/lib/ld-linux-x86-64.so.2 /lib

# build env setup
RUN \
	set -xe && \
	umask 022 && \
	rm -rf /packages && \
	mkdir -p /build /download /packages /control

# linux-devel
ADD control/linux-devel /control/linux-devel
RUN \
	set -xe && \
	umask 022 && \
	LC_ALL=POSIX && \
	TARGET_PLATFORM=$(uname -m)-uc-linux-gnu && \
	wget -O /download/linux-4.2.1.tar.xz -c \
		https://www.kernel.org/pub/linux/kernel/v4.x/linux-4.2.1.tar.xz && \
	cd /build && \
	mkdir -p destroot/usr/include && \
	tar xf /download/linux-4.2.1.tar.xz && \
	cd linux-4.2.1 && \
	make mrproper && \
	make INSTALL_HDR_PATH=dest headers_install && \
	cp -rv dest/include/* /build/destroot/usr/include && \
	make-deb \
		/build/linux-devel-deb \
		/build/destroot \
		/control/linux-devel \
		/packages/linux-devel_4.2.1-0_amd64.deb && \
	cd / && \
	rm -rf /build/* /download/* /control/* && \
	dpkg -i /packages/linux-devel_*.deb

# glibc-bootstrap
ADD control/libc-bootstrap /control/libc-bootstrap
ADD control/glibc-bin-bootstrap /control/glibc-bin-bootstrap
ADD control/libc-devel-bootstrap /control/libc-devel-bootstrap
RUN \
	set -xe && \
	umask 022 && \
	LC_ALL=POSIX && \
	TARGET_PLATFORM=$(uname -m)-uc-linux-gnu && \
	wget -O /download/glibc-2.22.tar.xz \
		http://ftp.gnu.org/gnu/glibc/glibc-2.22.tar.xz && \
	wget -O /download/glibc-2.22-fhs-1.patch \
		http://www.linuxfromscratch.org/patches/lfs/systemd/glibc-2.22-fhs-1.patch && \
	wget -O /download/glibc-2.22-upstream_i386_fix-1.patch \
		http://www.linuxfromscratch.org/patches/lfs/systemd/glibc-2.22-upstream_i386_fix-1.patch && \
	cd /build && \
	tar xf /download/glibc-2.22.tar.xz && \
	cd glibc-2.22 && \
	patch -Np1 -i /download/glibc-2.22-fhs-1.patch && \
	patch -Np1 -i /download/glibc-2.22-upstream_i386_fix-1.patch && \
	mkdir -p ../glibc-build && \
	cd ../glibc-build && \
	../glibc-2.22/configure \
		--prefix=/usr --disable-profile --enable-kernel=2.6.32\
		--enable-obsolete-rpc && \
	MAKE="make -j4" make && \
	mkdir -p /build/glibc-root/etc && \
	touch /build/glibc-root/etc/ld.so.conf && \
	make install_root=/build/glibc-root install && \
	rm -f /build/glibc-root/etc/ld.so.conf && \
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
	cd /build/glibc-root && \
	(strip --strip-debug lib64/* usr/lib64/* usr/lib64/*/* || true) && \
	(strip --strip-unneeded sbin/* usr/bin/* usr/sbin/* || true) && \
	rm -f etc/ld.so.cache && \
	rm -rf usr/share/locale && \
	rm -rf usr/lib64/gconv && \
	rm -rf usr/libexec/getconf && \
	rm -rf usr/libexec && \
	rm -rf usr/lib/locale && \
	rm -rf usr/share/i18n && \
	rm -f etc/rpc sbin/sln && \
	rm -rf var && \
	cp -a /build/glibc-root /build/libc-bootstrap-root && \
	cp -a /build/glibc-root /build/glibc-bin-bootstrap-root && \
	cp -a /build/glibc-root /build/libc-devel-bootstrap-root && \

	cd /build/libc-bootstrap-root && \
	cd usr/bin && \
	find -not -name ldd -delete && \
	cd ../.. && \
	rm -rf etc && \
	rm -rf usr/sbin && \
	rm -rf usr/lib && \
	rm -rf usr/share && \
	rm -rf usr/include && \
	find . -name "*.a" -delete && \
	find . -name "*.o" -delete && \
	make-deb \
		/build/libc-bootstrap-deb \
		/build/libc-bootstrap-root \
		/control/libc-bootstrap \
		/packages/libc-bootstrap_2.22-0_amd64.deb && \

	cd /build/glibc-bin-bootstrap-root && \
	cd usr/bin && \
	find -name ldd -delete && \
	cd ../.. && \
	rm -rf etc && \
	rm -rf usr/lib && \
	rm -rf usr/lib64 && \
	rm -rf usr/share && \
	rm -rf usr/include && \
	rm -rf lib64 sbin usr/lib64/audit && \
	find . -name "*.a" -delete && \
	find . -name "*.o" -delete && \
	make-deb \
		/build/glibc-bin-bootstrap-deb \
		/build/glibc-bin-bootstrap-root \
		/control/glibc-bin-bootstrap \
		/packages/glibc-bin-bootstrap_2.22-0_amd64.deb && \

	cd /build/libc-devel-bootstrap-root && \
	rm -rf etc lib64 sbin usr/bin usr/lib64/audit usr/share usr/sbin usr/lib && \
	find . -name "*.so" -delete && \
	make-deb \
		/build/libc-devel-bootstrap-deb \
		/build/libc-devel-bootstrap-root \
		/control/libc-devel-bootstrap \
		/packages/libc-devel-bootstrap_2.22-0_amd64.deb && \
	cd / && \
	rm -rf /build/* /download/* /control/*

# install new packages and fixup toolchain
RUN \
	set -x && \
	set +h && \
	umask 022 && \
	LC_ALL=POSIX && \
	TARGET_PLATFORM=$(uname -m)-uc-linux-gnu && \
	dpkg --force-depends -i /packages/linux-devel_*.deb && \
	dpkg --force-depends -i /packages/libc-bootstrap_*.deb && \
	dpkg --force-depends -i /packages/glibc-bin-bootstrap_*.deb && \
	dpkg --force-depends -i /packages/libc-devel-bootstrap_*.deb && \
	mv -v /tools/bin/{ld,ld-old} && \
	mv -v /tools/$(gcc -dumpmachine)/bin/{ld,ld-old} && \
	mv -v /tools/bin/{ld-new,ld} && \
	ln -sv /tools/bin/ld /tools/$(gcc -dumpmachine)/bin/ld && \
	gcc -dumpspecs | \
		sed 's@/tools@@g' | \
		sed '/\*startfile_prefix_spec:/{n;s@.*@/usr/lib/ @}' | \
		sed '/\*cpp:/{n;s@$@ -isystem /usr/include@}' > \
		`dirname $(gcc --print-libgcc-file-name)`/specs && \
	cd /build && \
	echo 'main(){}' > dummy.c && \
	cc dummy.c -v -Wl,--verbose &> dummy.log && \
	readelf -l a.out | grep ': /lib' && \
	grep -o '/usr/lib.*/crt[1in].*succeeded' dummy.log && \
	grep -B1 '^ /usr/include' dummy.log && \
	grep 'SEARCH.*/usr/lib' dummy.log |sed 's|; |\n|g' && \
	grep "/lib.*/libc.so.6 " dummy.log && \
	grep found dummy.log && \
	rm -v dummy.c a.out dummy.log

# libz-bootstrap
ADD control/libz-bootstrap /control/libz-bootstrap
ADD control/libz-devel-bootstrap /control/libz-devel-bootstrap
RUN \
	set -x && \
	set +h && \
	umask 022 && \
	LC_ALL=POSIX && \
	TARGET_PLATFORM=$(uname -m)-uc-linux-gnu && \
	wget -O /download/zlib-1.2.8.tar.xz \	
		http://www.zlib.net/zlib-1.2.8.tar.xz && \
	cd /build && \
	tar xf /download/zlib-1.2.8.tar.xz && \
	cd /build/zlib-1.2.8 && \
	./configure --prefix=/usr && \
	make && \
	mkdir -p /build/zlib-root && \
	make DESTDIR=/build/zlib-root install && \
	cd /build/zlib-root && \
	rm -rf usr/share && \
	cp -a /build/zlib-root /build/libz-bootstrap-root && \
	cd /build/libz-bootstrap-root && \
	rm -rf usr/include usr/lib/pkgconfig && \
	rm -f usr/lib/*.a && \
	(strip --strip-debug usr/lib/*.so* || true) && \
	rm -f lib/libz.so && \
	mkdir -p usr/lib && \
	make-deb \
		/build/libz-bootstrap-deb \
		/build/libz-bootstrap-root \
		/control/libz-bootstrap \
		/packages/libz-bootstrap_1.2.8-0_amd64.deb && \

	cp -a /build/zlib-root /build/libz-devel-bootstrap-root && \
	cd /build/libz-devel-bootstrap-root && \
	rm -f usr/lib/*.so* && \
	make-deb \
		/build/libz-devel-bootstrap-deb \
		/build/libz-devel-bootstrap-root \
		/control/libz-devel-bootstrap \
		/packages/libz-devel-bootstrap_1.2.8-0_amd64.deb && \
	cd / && \
	rm -rf /build/* /download/* /control/*

CMD ["/bin/sh"]
