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
	pre-root destroot && \
	mkdir -p destroot/usr/include && \
	tar xf /download/linux-4.2.1.tar.xz && \
	cd linux-4.2.1 && \
	make mrproper && \
	make INSTALL_HDR_PATH=dest headers_install && \
	cp -rv dest/include/* /build/destroot/usr/include && \
	post-root /build/destroot && \
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
	set -x && \
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
	pre-root /build/glibc-root && \
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
	(strip --strip-debug usr/lib/* usr/lib/*/* || true) && \
	(strip --strip-unneeded sbin/* usr/bin/* usr/sbin/* || true) && \
	rm -f etc/ld.so.cache && \
	rm -rf usr/share/locale && \
	rm -rf usr/lib/gconv && \
	rm -rf usr/libexec/getconf && \
	rm -rf usr/libexec && \
	rm -rf usr/lib/locale && \
	rm -rf usr/share/i18n && \
	rm -f etc/rpc usr/sbin/sln && \
	rm -rf var && \
	post-root /build/glibc-root && \

	cp -a /build/glibc-root /build/libc-bootstrap-root && \
	cd /build/libc-bootstrap-root && \
	cd usr/bin && \
	find -type f -not -name ldd -delete && \
	cd ../.. && \
	rm -rf etc && \
	cd usr/sbin && \
	find -type f -not -name ldconfig -delete && \
	cd ../.. && \
	rm -rf usr/share && \
	rm -rf usr/include && \
	find . -name "*.a" -delete && \
	find . -name "*.o" -delete && \
	make-deb \
		/build/libc-bootstrap-deb \
		/build/libc-bootstrap-root \
		/control/libc-bootstrap \
		/packages/libc-bootstrap_2.22-0_amd64.deb && \

	cp -a /build/glibc-root /build/glibc-bin-bootstrap-root && \
	cd /build/glibc-bin-bootstrap-root && \
	rm -f usr/bin/ldd && \
	rm -f usr/sbin/ldconfig && \
	rm -rf etc && \
	rm -rf usr/lib && \
	rm -rf usr/share && \
	rm -rf usr/include && \
	find . -name "*.a" -delete && \
	find . -name "*.o" -delete && \
	make-deb \
		/build/glibc-bin-bootstrap-deb \
		/build/glibc-bin-bootstrap-root \
		/control/glibc-bin-bootstrap \
		/packages/glibc-bin-bootstrap_2.22-0_amd64.deb && \

	cp -a /build/glibc-root /build/libc-devel-bootstrap-root && \
	cd /build/libc-devel-bootstrap-root && \
	rm -rf etc usr/bin usr/share usr/sbin && \
	find usr/lib -name "*.so*" -delete && \
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
	pre-root /build/zlib-root && \
	make DESTDIR=/build/zlib-root install && \
	cd /build/zlib-root && \
	rm -rf usr/share && \
	rm -f lib/libz.so && \
	post-root /build/zlib-root && \

	cp -a /build/zlib-root /build/libz-bootstrap-root && \
	cd /build/libz-bootstrap-root && \
	rm -rf usr/include usr/lib/pkgconfig && \
	rm -f usr/lib/*.a && \
	(strip --strip-debug usr/lib/*.so* || true) && \
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

# file-bootstrap
ADD control/file-bootstrap /control/file-bootstrap
ADD control/libmagic-bootstrap /control/libmagic-bootstrap
ADD control/libmagic-devel-bootstrap /control/libmagic-devel-bootstrap
RUN \
	set -x && \
	set +h && \
	umask 022 && \
	LC_ALL=POSIX && \
	TARGET_PLATFORM=$(uname -m)-uc-linux-gnu && \
	wget -O /download/file-5.24.tar.gz \
		ftp://ftp.astron.com/pub/file/file-5.24.tar.gz && \
	cd /build && \
	tar xf /download/file-5.24.tar.gz && \
	cd file-5.24 && \
	./configure --prefix=/usr && \
	MAKE="make -j4" make && \
	pre-root /build/file-root && \
	make DESTDIR=/build/file-root install && \
	cd /build/file-root && \
	rm -rf usr/share/man && \
	(strip --strip-unneeded usr/bin/* || true) && \
	(strip --strip-debug usr/lib/*.so* || true) && \
	post-root /build/file-root && \

	cp -a /build/file-root /build/file-bootstrap-root && \
	cd /build/file-bootstrap-root && \
	rm -rf usr/lib usr/include && \
	make-deb \
		/build/file-bootstrap-deb \
		/build/file-bootstrap-root \
		/control/file-bootstrap \
		/packages/file-bootstrap_5.24-0_amd64.deb && \

	cp -a /build/file-root /build/libmagic-bootstrap-root && \
	cd /build/libmagic-bootstrap-root && \
	rm -rf usr/include usr/share usr/bin && \
	rm -f usr/lib/*.la && \
	make-deb \
		/build/libmagic-bootstrap-deb \
		/build/libmagic-bootstrap-root \
		/control/libmagic-bootstrap \
		/packages/libmagic-bootstrap_5.24-0_amd64.deb && \

	cp -a /build/file-root /build/libmagic-devel-bootstrap-root && \
	cd /build/libmagic-devel-bootstrap-root && \
	rm -rf usr/share usr/bin usr/lib/*.so* && \
	make-deb \
		/build/libmagic-devel-bootstrap-deb \
		/build/libmagic-devel-bootstrap-root \
		/control/libmagic-devel-bootstrap \
		/packages/libmagic-devel-bootstrap_5.24-0_amd64.deb && \

	cd / && \
	rm -rf /build/* /download/* /control/*

# binutils-bootstrap
ADD control/binutils-bootstrap /control/binutils-bootstrap
ADD control/binutils-devel-bootstrap /control/binutils-devel-bootstrap
RUN \
	set -x && \
	set +h && \
	umask 022 && \
	LC_ALL=POSIX && \
	TARGET_PLATFORM=$(uname -m)-uc-linux-gnu && \
	wget -O /download/binutils-2.25.1.tar.bz2 \
		http://ftp.gnu.org/gnu/binutils/binutils-2.25.1.tar.bz2 && \
	cd /build && \
	tar xf /download/binutils-2.25.1.tar.bz2 && \
	mkdir binutils-build && \
	cd binutils-build && \
	../binutils-2.25.1/configure --prefix=/usr --enable-shared --disable-werror && \
	MAKE="make -j4" make tooldir=/usr && \
	pre-root /build/binutils-root && \
	make DESTDIR=/build/binutils-root tooldir=/usr install && \
	cd /build/binutils-root && \
	rm -rf usr/share && \
	(strip --strip-debug usr/lib/* || true) && \
	(strip --strip-unneeded usr/bin/* || true) && \
	post-root /build/binutils-root && \

	cp -a /build/binutils-root /build/binutils-bootstrap-root && \
	cd /build/binutils-bootstrap-root && \
	rm -rf usr/include usr/lib/*.a usr/lib/*.la && \
	make-deb \
		/build/binutils-bootstrap-deb \
		/build/binutils-bootstrap-root \
		/control/binutils-bootstrap \
		/packages/binutils-bootstrap_2.25.1-0_amd64.deb && \

	cp -a /build/binutils-root /build/binutils-devel-bootstrap-root && \
	cd /build/binutils-devel-bootstrap-root && \
	rm -rf usr/bin usr/lib/ldscripts usr/lib/*.so* && \
	make-deb \
		/build/binutils-devel-bootstrap-deb \
		/build/binutils-devel-bootstrap-root \
		/control/binutils-devel-bootstrap \
		/packages/binutils-devel-bootstrap_2.25.1-0_amd64.deb && \

	cd / && \
	rm -rf /build/* /download/* /control/* && \
	dpkg --force-depends -i /packages/binutils-bootstrap_*.deb && \
	dpkg --force-depends -i /packages/libmagic-bootstrap_*.deb && \
	dpkg --force-depends -i /packages/file-bootstrap_*.deb

# m4-bootstrap
ADD control/m4-bootstrap /control/m4-bootstrap
RUN \
	set -x && \
	set +h && \
	umask 022 && \
	LC_ALL=POSIX && \
	TARGET_PLATFORM=$(uname -m)-uc-linux-gnu && \
	wget -O /download/m4-1.4.17.tar.xz \
		http://ftp.gnu.org/gnu/m4/m4-1.4.17.tar.xz && \
	cd /build && \
	tar xf /download/m4-1.4.17.tar.xz && \
	cd m4-1.4.17 && \
	./configure --prefix=/usr && \
	MAKE="make -j4" make && \
	pre-root /build/m4-bootstrap-root && \
	make DESTDIR=/build/m4-bootstrap-root install && \
	cd /build/m4-bootstrap-root && \
	rm -rf usr/share && \
	(strip --strip-unneeded usr/bin/* || true) && \
	post-root /build/m4-bootstrap-root && \
	make-deb \
		/build/m4-bootstrap-deb \
		/build/m4-bootstrap-root \
		/control/m4-bootstrap \
		/packages/m4-bootstrap_1.4.17-0_amd64.deb && \
	cd / && \
	rm -rf /build/* /download/* /control/* && \
	dpkg --force-depends -i /packages/m4-bootstrap_*.deb

# libgmp-bootstrap, libgmp-devel-bootstrap
ADD control/libgmp-bootstrap /control/libgmp-bootstrap
ADD control/libgmp-devel-bootstrap /control/libgmp-devel-bootstrap
RUN \
	set -x && \
	set +h && \
	umask 022 && \
	LC_ALL=POSIX && \
	TARGET_PLATFORM=$(uname -m)-uc-linux-gnu && \
	wget -O /download/gmp-6.0.0a.tar.xz \
		http://ftp.gnu.org/gnu/gmp/gmp-6.0.0a.tar.xz && \
	cd /build && \
	tar xf /download/gmp-6.0.0a.tar.xz && \
	cd gmp-6.0.0 && \
	./configure --prefix=/usr --enable-cxx --disable-static && \
	MAKE="make -j4" make && \
	pre-root /build/gmp-root && \
	make DESTDIR=/build/gmp-root install && \
	cd /build/gmp-root && \
	rm -rf usr/share && \
	(strip --strip-debug usr/lib/* || true) && \
	post-root /build/gmp-root && \

	cp -a /build/gmp-root /build/libgmp-bootstrap-root && \
	cd /build/libgmp-bootstrap-root && \
	rm -rf usr/include && \
	rm -rf usr/lib/*.la && \
	make-deb \
		/build/libgmp-bootstrap-deb \
		/build/libgmp-bootstrap-root \
		/control/libgmp-bootstrap \
		/packages/libgmp-bootstrap_6.0.0a-0_amd64.deb && \

	cp -a /build/gmp-root /build/libgmp-devel-bootstrap-root && \
	cd /build/libgmp-devel-bootstrap-root && \
	rm -f usr/lib/*.so* && \
	make-deb \
		/build/libgmp-devel-bootstrap-deb \
		/build/libgmp-devel-bootstrap-root \
		/control/libgmp-devel-bootstrap \
		/packages/libgmp-devel-bootstrap_6.0.0a-0_amd64.deb && \

	cd / && \
	rm -rf /build/* /download/* /control/* && \
	dpkg --force-depends -i /packages/libgmp-bootstrap_*.deb && \
	dpkg --force-depends -i /packages/libgmp-devel-bootstrap_*.deb

# patch-bootstrap
ADD control/patch-bootstrap /control/patch-bootstrap
RUN \
	set -x && \
	set +h && \
	umask 022 && \
	LC_ALL=POSIX && \
	TARGET_PLATFORM=$(uname -m)-uc-linux-gnu && \
	wget -O /download/patch-2.7.5.tar.xz \
		http://ftp.gnu.org/gnu/patch/patch-2.7.5.tar.xz && \
	cd /build && \
	tar xf /download/patch-2.7.5.tar.xz && \
	cd patch-2.7.5 && \
	./configure --prefix=/usr && \
	MAKE="make -j4" make && \
	pre-root /build/patch-bootstrap-root && \
	make DESTDIR=/build/patch-bootstrap-root install && \
	cd /build/patch-bootstrap-root && \
	rm -rf usr/share && \
	(strip --strip-unneeded usr/bin/* || true) && \
	post-root /build/patch-bootstrap-root && \
	make-deb \
		/build/patch-bootstrap-deb \
		/build/patch-bootstrap-root \
		/control/patch-bootstrap \
		/packages/patch-bootstrap_2.7.5-0_amd64.deb && \
	cd / && \
        rm -rf /build/* /download/* /control/* && \
	dpkg --force-depends -i /packages/patch-bootstrap_*.deb

# libmpfr-bootstrap, libmpfr-devel-bootstrap
ADD control/libmpfr-bootstrap /control/libmpfr-bootstrap
ADD control/libmpfr-devel-bootstrap /control/libmpfr-devel-bootstrap
RUN \
	set -x && \
	set +h && \
	umask 022 && \
	LC_ALL=POSIX && \
	TARGET_PLATFORM=$(uname -m)-uc-linux-gnu && \
	wget -O /download/mpfr-3.1.3.tar.xz \
		http://www.mpfr.org/mpfr-3.1.3/mpfr-3.1.3.tar.xz && \
	wget -O /download/mpfr-3.1.3-upstream_fixes-1.patch \
		http://www.linuxfromscratch.org/patches/lfs/systemd/mpfr-3.1.3-upstream_fixes-1.patch && \
	cd /build && \
	tar xf /download/mpfr-3.1.3.tar.xz && \
	cd mpfr-3.1.3 && \
	patch -Np1 -i /download/mpfr-3.1.3-upstream_fixes-1.patch && \
	./configure --prefix=/usr --disable-static --enable-thread-safe && \
	MAKE="make -j4" make && \
	pre-root /build/mpfr-root && \
	make DESTDIR=/build/mpfr-root install && \
	cd /build/mpfr-root && \
	rm -rf usr/share && \
	(strip --strip-debug usr/lib/* || true) && \
	post-root /build/mpfr-root && \

	cp -a /build/mpfr-root /build/libmpfr-bootstrap-root && \
	cd /build/libmpfr-bootstrap-root && \
	rm -rf usr/include && \
	rm -f usr/lib/*.la && \
	make-deb \
		/build/libmpfr-bootstrap-deb \
		/build/libmpfr-bootstrap-root \
		/control/libmpfr-bootstrap \
		/packages/libmpfr-bootstrap_3.1.3-0_amd64.deb && \

	cp -a /build/mpfr-root /build/libmpfr-devel-bootstrap-root && \
	cd /build/libmpfr-devel-bootstrap-root && \
	rm -f usr/lib/*.so* && \
	make-deb \
		/build/libmpfr-devel-bootstrap-deb \
		/build/libmpfr-devel-bootstrap-root \
		/control/libmpfr-devel-bootstrap \
		/packages/libmpfr-devel-bootstrap_3.1.3-0_amd64.deb && \

	cd / && \
	rm -rf /build/* /download/* /control/* && \
	dpkg --force-depends -i /packages/libmpfr-bootstrap_*.deb && \
	dpkg --force-depends -i /packages/libmpfr-devel-bootstrap_*.deb

# libmpc-bootstrap, libmpc-devel-bootstrap
# http://www.multiprecision.org/mpc/download/mpc-1.0.3.tar.gz
ADD control/libmpc-bootstrap /control/libmpc-bootstrap
ADD control/libmpc-devel-bootstrap /control/libmpc-devel-bootstrap
RUN \
	set -x && \
	set +h && \
	umask 022 && \
	LC_ALL=POSIX && \
	TARGET_PLATFORM=$(uname -m)-uc-linux-gnu && \
	wget -O /download/mpc-1.0.3.tar.gz \
		http://www.multiprecision.org/mpc/download/mpc-1.0.3.tar.gz && \
	cd /build && \
	tar xf /download/mpc-1.0.3.tar.gz && \
	cd mpc-1.0.3 && \
	./configure --prefix=/usr --disable-static && \
	MAKE="make -j4" make && \
	pre-root /build/mpc-root && \
	make DESTDIR=/build/mpc-root install && \
	rm -rf usr/share && \
	(strip --strip-debug usr/lib/* || true) && \
	post-root /build/mpc-root && \

	cp -a /build/mpc-root /build/libmpc-bootstrap-root && \
	cd /build/libmpc-bootstrap-root && \
	rm -rf usr/include && \
	rm -f usr/lib/*.la && \
	make-deb \
		/build/libmpc-bootstrap-deb \
		/build/libmpc-bootstrap-root \
		/control/libmpc-bootstrap \
		/packages/libmpc-bootstrap_1.0.3-0_amd64.deb && \

	cp -a /build/mpc-root /build/libmpc-devel-bootstrap-root && \
	cd /build/libmpc-devel-bootstrap-root && \
	rm -f usr/lib/*.so* && \
	make-deb \
		/build/libmpc-devel-bootstrap-deb \
		/build/libmpc-devel-bootstrap-root \
		/control/libmpc-devel-bootstrap \
		/packages/libmpc-devel-bootstrap_1.0.3-0_amd64.deb && \

	cd / && \
        rm -rf /build/* /download/* /control/* && \
	dpkg --force-depends -i /packages/libmpc-bootstrap_*.deb && \
	dpkg --force-depends -i /packages/libmpc-devel-bootstrap_*.deb

CMD ["/bin/sh"]
