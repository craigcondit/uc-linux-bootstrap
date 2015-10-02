FROM scratch
MAINTAINER ccondit@randomcoder.com
ADD stage2.tar.xz /
ADD Manifest /Manifest

ENV PATH /usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin

RUN \
	set -x && \
	umask 022 && \
	LC_ALL=POSIX && \
	mkdir -p /bootstrap /download /packages /build /control && \
	cd /bootstrap && \
	for pkg in $(cat /Manifest) ; do wget -O "$(echo $pkg | sed 's@.*/@@')" "${pkg}" ; done && \
	for pkg in $(cat /Manifest) ; do dpkg --force-depends -i "$(echo $pkg | sed 's@.*/@@')" ; done

# make
ADD control/make /control/make
RUN \
	set -x && \
	umask 022 && \
	LC_ALL=POSIX && \
	wget -O /download/make-4.1.tar.bz2 \
		http://ftp.gnu.org/gnu/make/make-4.1.tar.bz2 && \
	cd /build && \
	tar xf /download/make-4.1.tar.bz2 && \
	cd make-4.1 && \
	./configure --prefix=/usr --without-guile && \
	sh ./build.sh && \
	./make && \
	pre-root /build/make-root && \
	./make DESTDIR=/build/make-root install-strip && \
	post-root /build/make-root && \
	cd /build/make-root && \
	rm -rf usr/share usr/include && \

	make-deb \
		/build/make-deb \
		/build/make-root \
		/control/make \
		/packages/make_4.1-0_amd64.deb && \
	cd / && \
	rm -rf /build/* /download/* /control/* && \
	dpkg --force-depends -i /packages/make_*.deb

# binutils
ADD control/binutils-all /control
RUN \
	set -x && \
	umask 022 && \
	LC_ALL=POSIX && \
	TARGET_PLATFORM=$(uname -m)-uc-linux-gnu && \
	wget -O /download/binutils-2.25.1.tar.bz2 \
		http://ftp.gnu.org/gnu/binutils/binutils-2.25.1.tar.bz2 && \
	cd /build && \
	tar xf /download/binutils-2.25.1.tar.bz2 && \
	mkdir binutils-build && \
	cd binutils-build && \
	CC=gcc CXX=g++ AR=ar RANLIB=ranlib LD=ld STRIP=strip \
	../binutils-2.25.1/configure \
		--prefix=/usr --enable-shared --disable-werror \
		--target="${TARGET_PLATFORM}" --host="${TARGET_PLATFORM}" \
		--disable-multilib --with-build-sysroot=/ && \
	MAKE="make -j4" make tooldir=/usr && \
	pre-root /build/binutils-master-root && \
	make DESTDIR=/build/binutils-master-root tooldir=/usr install && \
	cd /build/binutils-master-root && \
	rm -rf usr/share && \
	(strip --strip-debug usr/lib/* || true) && \
	(strip --strip-unneeded usr/bin/* || true) && \
	post-root /build/binutils-master-root && \

	cp -a /build/binutils-master-root /build/binutils-root && \
	cd /build/binutils-root && \
	rm -rf usr/include usr/lib/*.a usr/lib/*.la && \
	make-deb \
		/build/binutils-deb \
		/build/binutils-root \
		/control/binutils \
		/packages/binutils_2.25.1-0_amd64.deb && \

	cp -a /build/binutils-master-root /build/binutils-devel-root && \
	cd /build/binutils-devel-root && \
	rm -rf usr/bin usr/lib/ldscripts usr/lib/*.so* && \
	make-deb \
		/build/binutils-devel-deb \
		/build/binutils-devel-root \
		/control/binutils-devel \
		/packages/binutils-devel_2.25.1-0_amd64.deb && \

	cd / && \
	rm -rf /build/* /download/* /control/* && \
	dpkg --force-depends -P binutils-bootstrap binutils-devel-bootstrap && \
	dpkg --force-depends -i /packages/binutils_*.deb

# pkg-config
ADD control/pkg-config /control/pkg-config
RUN \
	set -x && \
	umask 022 && \
	LC_ALL=POSIX && \
	wget -O /download/pkg-config-0.28.tar.gz \
		http://pkgconfig.freedesktop.org/releases/pkg-config-0.28.tar.gz && \
	cd /build && \
	tar xf /download/pkg-config-0.28.tar.gz && \
	cd pkg-config-0.28 && \
	./configure --prefix=/usr --with-internal-glib --disable-host-tool && \
	MAKE="make -j4" make && \
	pre-root /build/pkg-config-root && \
	make DESTDIR=/build/pkg-config-root install && \
	post-root /build/pkg-config-root && \
	cd /build/pkg-config-root && \
	rm -rf usr/share/doc usr/share/man && \
	(strip --strip-unneeded usr/bin/* || true) && \
	make-deb \
		/build/pkg-config-deb \
		/build/pkg-config-root \
		/control/pkg-config \
		/packages/pkg-config_0.28-0_amd64.deb && \
	cd / && \
	rm -rf /build/* /download/* /control/* && \
	dpkg --force-depends -i /packages/pkg-config_*.deb

# gawk
ADD control/gawk /control/gawk
RUN \
	set -x && \
	umask 022 && \
	LC_ALL=POSIX && \
	wget -O /download/gawk-4.1.3.tar.xz \
		http://ftp.gnu.org/gnu/gawk/gawk-4.1.3.tar.xz && \
	cd /build && \
	tar xf /download/gawk-4.1.3.tar.xz && \
	cd gawk-4.1.3 && \
	./configure --prefix=/usr && \
	MAKE="make -j4" make && \
	pre-root /build/gawk-root && \
	make DESTDIR=/build/gawk-root install-strip && \
	post-root /build/gawk-root && \
	cd /build/gawk-root && \
	rm -rf usr/share/info usr/share/locale usr/share/man && \
	rm -f usr/bin/gawk-4.1.3 && \
	make-deb \
		/build/gawk-deb \
		/build/gawk-root \
		/control/gawk \
		/packages/gawk_4.1.3-0_amd64.deb && \
	cd / && \
	rm -rf /build/* /download/* /control/* && \
	dpkg --force-depends -i /packages/gawk_*.deb

# sed
ADD control/sed /control/sed
RUN \
	set -x && \
	umask 022 && \
	LC_ALL=POSIX && \
	wget -O /download/sed-4.2.2.tar.bz2 \
		http://ftp.gnu.org/gnu/sed/sed-4.2.2.tar.bz2 && \
	cd /build && \
	tar xf /download/sed-4.2.2.tar.bz2 && \
	cd sed-4.2.2 && \
	./configure --prefix=/usr && \
	MAKE="make -j4" make && \
	pre-root /build/sed-root && \
	make DESTDIR=/build/sed-root install-strip && \
	post-root /build/sed-root && \
	cd /build/sed-root && \
	rm -rf usr/share && \
	make-deb \
		/build/sed-deb \
		/build/sed-root \
		/control/sed\
		/packages/sed_4.2.2-0_amd64.deb && \
	cd / && \
	rm -rf /build/* /download/* /control/* && \
	dpkg --force-depends -i /packages/sed_*.deb

# glibc
ADD control/glibc-all /control
RUN \
	set -x && \
	umask 022 && \
	LC_ALL=POSIX && \
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
	sed -i 's@/usr/bin/bash@/bin/sh@' usr/bin/ldd && \
	post-root /build/glibc-root && \

	cp -a /build/glibc-root /build/libc-root && \
	cd /build/libc-root && \
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
		/build/libc-deb \
		/build/libc-root \
		/control/libc \
		/packages/libc_2.22-0_amd64.deb && \

	cp -a /build/glibc-root /build/glibc-bin-root && \
	cd /build/glibc-bin-root && \
	rm -f usr/bin/ldd && \
	rm -f usr/sbin/ldconfig && \
	rm -rf etc && \
	rm -rf usr/lib && \
	rm -rf usr/share && \
	rm -rf usr/include && \
	find . -name "*.a" -delete && \
	find . -name "*.o" -delete && \
	make-deb \
		/build/glibc-bin-deb \
		/build/glibc-bin-root \
		/control/glibc-bin \
		/packages/glibc-bin_2.22-0_amd64.deb && \

	cp -a /build/glibc-root /build/libc-devel-root && \
	cd /build/libc-devel-root && \
	rm -rf etc usr/bin usr/share usr/sbin && \
	find usr/lib -name "*.so*" -delete && \
	make-deb \
		/build/libc-devel-deb \
		/build/libc-devel-root \
		/control/libc-devel \
		/packages/libc-devel_2.22-0_amd64.deb && \
	dpkg --force-depends -P \
		libc-devel-bootstrap glibc-bin-bootstrap libc-bootstrap && \
	LD_LIBRARY_PATH=/build/libc-root/usr/lib \
	/build/libc-root/usr/lib/ld-linux-x86-64.so.2 \
	/usr/bin/dpkg --force-depends -i /packages/libc_*.deb && \
	dpkg --force-depends -i /packages/glibc-bin_*.deb && \
	dpkg --force-depends -i /packages/libc-devel_*.deb && \
	cd / && \
	rm -rf /build/* /download/* /control/*

# libz
ADD control/libz-all /control
RUN \
	set -x && \
	umask 022 && \
	LC_ALL=POSIX && \
	wget -O /download/zlib-1.2.8.tar.xz \	
		http://www.zlib.net/zlib-1.2.8.tar.xz && \
	cd /build && \
	tar xf /download/zlib-1.2.8.tar.xz && \
	cd /build/zlib-1.2.8 && \
	CFLAGS='-mstackrealign -fPIC -O3' ./configure --prefix=/usr && \
	MAKE="make -j4" make && \
	pre-root /build/zlib-root && \
	make DESTDIR=/build/zlib-root install && \
	cd /build/zlib-root && \
	rm -rf usr/share && \
	rm -f lib/libz.so && \
	post-root /build/zlib-root && \

	cp -a /build/zlib-root /build/libz-root && \
	cd /build/libz-root && \
	rm -rf usr/include usr/lib/pkgconfig && \
	rm -f usr/lib/*.a && \
	(strip --strip-debug usr/lib/*.so* || true) && \
	make-deb \
		/build/libz-deb \
		/build/libz-root \
		/control/libz\
		/packages/libz_2.8-0_amd64.deb && \

	cp -a /build/zlib-root /build/libz-devel-root && \
	cd /build/libz-devel-root && \
	rm -f usr/lib/*.so* && \
	make-deb \
		/build/libz-devel-deb \
		/build/libz-devel-root \
		/control/libz-devel \
		/packages/libz-devel_2.8-0_amd64.deb && \
	cd / && \
	rm -rf /build/* /download/* /control/* && \
	dpkg --force-depends -P libz-bootstrap libz-devel-bootstrap && \
	dpkg --force-depends -i /packages/libz_*.deb && \
	dpkg --force-depends -i /packages/libz-devel_*.deb

# file
ADD control/file-all /control
RUN \
	set -x && \
	umask 022 && \
	LC_ALL=POSIX && \
	wget -O /download/file-5.25.tar.gz \
		ftp://ftp.astron.com/pub/file/file-5.25.tar.gz && \
	cd /build && \
	tar xf /download/file-5.25.tar.gz && \
	cd file-5.25 && \
	./configure --prefix=/usr && \
	MAKE="make -j4" make && \
	pre-root /build/file-root-orig && \
	make DESTDIR=/build/file-root-orig install && \
	cd /build/file-root-orig && \
	rm -rf usr/share/man && \
	(strip --strip-unneeded usr/bin/* || true) && \
	(strip --strip-debug usr/lib/*.so* || true) && \
	post-root /build/file-root-orig && \

	cp -a /build/file-root-orig /build/file-root && \
	cd /build/file-root && \
	rm -rf usr/lib usr/include && \
	make-deb \
		/build/file-deb \
		/build/file-root \
		/control/file \
		/packages/file_5.25-0_amd64.deb && \

	cp -a /build/file-root-orig /build/libmagic-root && \
	cd /build/libmagic-root && \
	rm -rf usr/include usr/share usr/bin && \
	rm -f usr/lib/*.la && \
	make-deb \
		/build/libmagic-deb \
		/build/libmagic-root \
		/control/libmagic \
		/packages/libmagic_5.25-0_amd64.deb && \

	cp -a /build/file-root-orig /build/libmagic-devel-root && \
	cd /build/libmagic-devel-root && \
	rm -rf usr/share usr/bin usr/lib/*.so* && \
	make-deb \
		/build/libmagic-devel-deb \
		/build/libmagic-devel-root \
		/control/libmagic-devel \
		/packages/libmagic-devel_5.25-0_amd64.deb && \

	cd / && \
	rm -rf /build/* /download/* /control/* && \
	dpkg --force-depends -P file-bootstrap libmagic-bootstrap libmagic-devel-bootstrap && \
	dpkg --force-depends -i \
		/packages/libmagic_*.deb /packages/libmagic-devel_*.deb /packages/file_*.deb

# libgmp
ADD control/libgmp-all /control
RUN \
	set -x && \
	umask 022 && \
	LC_ALL=POSIX && \
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

	cp -a /build/gmp-root /build/libgmp-root && \
	cd /build/libgmp-root && \
	rm -rf usr/include && \
	rm -rf usr/lib/*.la && \
	make-deb \
		/build/libgmp-deb \
		/build/libgmp-root \
		/control/libgmp \
		/packages/libgmp_6.0.0a-0_amd64.deb && \

	cp -a /build/gmp-root /build/libgmp-devel-root && \
	cd /build/libgmp-devel-root && \
	rm -f usr/lib/*.so* && \
	make-deb \
		/build/libgmp-devel-deb \
		/build/libgmp-devel-root \
		/control/libgmp-devel \
		/packages/libgmp-devel_6.0.0a-0_amd64.deb && \

	cd / && \
	rm -rf /build/* /download/* /control/* && \
	dpkg --force-depends -P libgmp-bootstrap libgmp-devel-bootstrap && \
	dpkg --force-depends -i /packages/libgmp_*.deb /packages/libgmp-devel_*.deb

# libmpfr
ADD control/libmpfr-all /control
RUN \
	set -x && \
	umask 022 && \
	LC_ALL=POSIX && \
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

	cp -a /build/mpfr-root /build/libmpfr-root && \
	cd /build/libmpfr-root && \
	rm -rf usr/include && \
	rm -f usr/lib/*.la && \
	make-deb \
		/build/libmpfr-deb \
		/build/libmpfr-root \
		/control/libmpfr \
		/packages/libmpfr_3.1.3-0_amd64.deb && \

	cp -a /build/mpfr-root /build/libmpfr-devel-root && \
	cd /build/libmpfr-devel-root && \
	rm -f usr/lib/*.so* && \
	make-deb \
		/build/libmpfr-devel-deb \
		/build/libmpfr-devel-root \
		/control/libmpfr-devel \
		/packages/libmpfr-devel_3.1.3-0_amd64.deb && \

	cd / && \
	rm -rf /build/* /download/* /control/* && \
	dpkg --force-depends -P libmpfr-bootstrap libmpfr-devel-bootstrap && \
	dpkg --force-depends -i /packages/libmpfr_*.deb /packages/libmpfr-devel_*.deb

# libmpc
ADD control/libmpc-all /control
RUN \
	set -x && \
	umask 022 && \
	LC_ALL=POSIX && \
	wget -O /download/mpc-1.0.3.tar.gz \
		http://www.multiprecision.org/mpc/download/mpc-1.0.3.tar.gz && \
	cd /build && \
	tar xf /download/mpc-1.0.3.tar.gz && \
	cd mpc-1.0.3 && \
	./configure --prefix=/usr --disable-static && \
	MAKE="make -j4" make && \
	pre-root /build/mpc-root && \
	make DESTDIR=/build/mpc-root install && \
        cd /build/mpc-root && \
	rm -rf usr/share && \
	(strip --strip-debug usr/lib/* || true) && \
	post-root /build/mpc-root && \

	cp -a /build/mpc-root /build/libmpc-root && \
	cd /build/libmpc-root && \
	rm -rf usr/include && \
	rm -f usr/lib/*.la && \
	make-deb \
		/build/libmpc-deb \
		/build/libmpc-root \
		/control/libmpc \
		/packages/libmpc_1.0.3-1_amd64.deb && \

	cp -a /build/mpc-root /build/libmpc-devel-root && \
	cd /build/libmpc-devel-root && \
	rm -f usr/lib/*.so* && \
	make-deb \
		/build/libmpc-devel-deb \
		/build/libmpc-devel-root \
		/control/libmpc-devel \
		/packages/libmpc-devel_1.0.3-1_amd64.deb && \

	cd / && \
        rm -rf /build/* /download/* /control/* && \
	dpkg --force-depends -P libmpc-bootstrap && \
	dpkg --force-depends -i /packages/libmpc_*.deb /packages/libmpc-devel_*.deb

# gcc
ADD control/gcc-all /control
RUN \
	set -x && \
	set +h && \
	umask 022 && \
	LC_ALL=POSIX && \
	TARGET_PLATFORM=$(uname -m)-uc-linux-gnu && \
	wget -O /download/gcc-5.2.0.tar.bz2 \
		http://ftp.gnu.org/gnu/gcc/gcc-5.2.0/gcc-5.2.0.tar.bz2 && \
	cd /build && \
	tar xf /download/gcc-5.2.0.tar.bz2 && \
	mkdir gcc-build && \
	cd gcc-build && \
	SED=sed CC=gcc CXX=g++ AR=ar RANLIB=ranlib LD=ld STRIP=strip \
	../gcc-5.2.0/configure \
		--prefix=/usr --enable-languages=c,c++ --disable-multilib \
		--disable-bootstrap --with-system-zlib \
		--host="${TARGET_PLATFORM}" --target="${TARGET_PLATFORM}" \
		--with-build-sysroot=/ && \
	MAKE="make -j4" make && \
	pre-root /build/gcc-root && \
	make DESTDIR=/build/gcc-root install-strip && \
	post-root /build/gcc-root && \
	cd /build/gcc-root && \
	rm -f usr/bin/${TARGET_PLATFORM}-* && \
	for tool in c++ g++ gcc gcc-ar gcc-nm gcc-ranlib ; do ln -sf $tool usr/bin/${TARGET_PLATFORM}-$tool ; done && \
	ln -sf gcc usr/bin/${TARGET_PLATFORM}-gcc-5.2.0 && \
	ln -sv ../bin/cpp usr/lib/cpp && \
	ln -sv gcc usr/bin/cc && \
	mkdir -p usr/lib/bfd-plugins && \
	ln -sfv ../../libexec/gcc/${TARGET_PLATFORM}/5.2.0/liblto_plugin.so usr/lib/bfd-plugins/ && \
	mkdir -pv usr/share/gdb/auto-load/usr/lib && \
	mv -v usr/lib/*gdb.py usr/share/gdb/auto-load/usr/lib && \
	rm -f usr/lib/libsupc++* && \
	rm -rf usr/share/info usr/share/locale usr/share/man && \

	for pkg in libasan libatomic libcilkrts libgcc libgomp libitm \
		liblsan libquadmath libssp libtsan libubsan libvtv ; do ( \
		mkdir -p /build/${pkg}-root/usr/lib && \
		cp -a usr/lib/${pkg}*.so* /build/${pkg}-root/usr/lib/ && \
		rm -f usr/lib/${pkg}*.so* && \
		make-deb \
			/build/${pkg}-deb \
			/build/${pkg}-root \
			/control/${pkg} \
			/packages/${pkg}_5.2.0-0_amd64.deb) ; done && \

	mkdir -p /build/libstdcxx-root/usr/lib && \
	cp -a usr/lib/libstdc++*.so* /build/libstdcxx-root/usr/lib/ && \
	rm -f usr/lib/libstdc++*.so* && \
	make-deb \
		/build/libstdcxx-deb \
		/build/libstdcxx-root \
		/control/libstdcxx \
		/packages/libstdcxx_5.2.0-0_amd64.deb && \

	make-deb \
		/build/gcc-deb \
		/build/gcc-root \
		/control/gcc \
		/packages/gcc_5.2.0-0_amd64.deb && \

	cd / && \
	rm -rf /build/* /download/* /control/* && \
	for pkg in libasan libatomic libcilkrts libgcc libgomp libitm \
		liblsan libquadmath libssp libstdcxx libtsan libubsan libvtv gcc ; do \
		dpkg --force-depends -P ${pkg} && \
		dpkg --force-depends -i /packages/${pkg}_*.deb ; done && \
	echo 'int main(){}' > dummy.c && \
	cc dummy.c -v -Wl,--verbose &> dummy.log && \
	readelf -l a.out | grep ': /lib' && \
	grep -o '/usr/lib.*/crt[1in].*succeeded' dummy.log && \
	grep -B4 '^ /usr/include' dummy.log && \
	grep 'SEARCH.*/usr/lib' dummy.log |sed 's|; |\n|g' && \
	grep "/lib.*/libc.so.6 " dummy.log && \
	grep found dummy.log && \
	rm -v dummy.c a.out dummy.log

CMD ["/bin/sh"]
