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
	for pkg in $(cat /Manifest) ; do dpkg --force-depends -i "$(echo $pkg | sed 's@.*/@@')" ; done && \
	ls -la

# make
ADD control/make /control/make
RUN \
	set -x && \
	umask 022 && \
	LC_ALL=POSIX && \
	TARGET_PLATFORM=$(uname -m)-uc-linux-gnu && \
	wget -O /download/make-4.2.1.tar.bz2 \
		http://ftp.gnu.org/gnu/make/make-4.2.1.tar.bz2 && \
	cd /build && \
	tar xf /download/make-4.2.1.tar.bz2 && \
	cd make-4.2.1 && \
	./configure --prefix=/usr  --without-guile --build="${TARGET_PLATFORM}" && \
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
		/packages/make_4.2.1-1_amd64.deb && \
	cd / && \
	rm -rf /build/* /download/* /control/* && \
	dpkg --force-depends -i /packages/make_*.deb

# update-alternatives
ADD patches/update-alternatives /patches/update-alternatives
ADD control/update-alternatives /control/update-alternatives
RUN \
	set -x && \
	umask 022 && \
	LC_ALL=POSIX && \
	TARGET_PLATFORM=$(uname -m)-uc-linux-gnu && \
	wget -O /download/dpkg_1.18.10.tar.xz \
		http://http.debian.net/debian/pool/main/d/dpkg/dpkg_1.18.10.tar.xz && \
	cd /build && \
	tar xf /download/dpkg_1.18.10.tar.xz && \
	cd dpkg-1.18.10 && \
	patch -p1 < \
		/patches/update-alternatives/update-alternatives-bootstrap.patch && \
	./configure --prefix=/usr --sysconfdir=/etc && \
	sed -i 's/debian-dpkg@lists.debian.org/insideo@randomcoder.org/' config.h && \
	sed -i 's/dpkg/update-alternatives/g' config.h && \
	cd lib/compat && \
	make && \
	cd ../../utils && \
	make admindir=/var/lib logdir=/var/log && \
	strip --strip-unneeded update-alternatives && \
	pre-root /build/update-alternatives-root && \
	cp update-alternatives /build/update-alternatives-root/usr/bin/ && \
	cd /build/update-alternatives-root && \
	chmod 755 usr/bin/update-alternatives && \
	mkdir -p etc/alternatives var/lib/alternatives && \
	post-root /build/update-alternatives-root && \
	make-deb \
		/build/update-alternatives-deb \
		/build/update-alternatives-root \
		/control/update-alternatives \
		/packages/update-alternatives_1.18.10-1_amd64.deb && \
	cd / && \
	rm -rf /build/* /download/* /control/* /patches/* && \
	dpkg --force-depends -i /packages/update-alternatives_*.deb

# binutils
ADD control/binutils-all /control
RUN \
	set -x && \
	umask 022 && \
	LC_ALL=POSIX && \
	TARGET_PLATFORM=$(uname -m)-uc-linux-gnu && \
	wget -O /download/binutils-2.27.tar.bz2 \
		http://ftp.gnu.org/gnu/binutils/binutils-2.27.tar.bz2 && \
	cd /build && \
	tar xf /download/binutils-2.27.tar.bz2 && \
	mkdir binutils-build && \
	cd binutils-build && \
	CC=gcc CXX=g++ AR=ar RANLIB=ranlib LD=ld STRIP=strip \
	../binutils-2.27/configure \
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
	mv usr/bin/ar usr/bin/ar.binutils && \
	mv usr/bin/strings usr/bin/strings.binutils && \
	make-deb \
		/build/binutils-deb \
		/build/binutils-root \
		/control/binutils \
		/packages/binutils_2.27.0-1_amd64.deb && \

	cp -a /build/binutils-master-root /build/binutils-devel-root && \
	cd /build/binutils-devel-root && \
	rm -rf usr/bin usr/lib/ldscripts usr/lib/*.so* && \
	make-deb \
		/build/binutils-devel-deb \
		/build/binutils-devel-root \
		/control/binutils-devel \
		/packages/binutils-devel_2.27.0-1_amd64.deb && \

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
	wget -O /download/pkg-config-0.29.1.tar.gz \
		http://pkgconfig.freedesktop.org/releases/pkg-config-0.29.1.tar.gz && \
	cd /build && \
	tar xf /download/pkg-config-0.29.1.tar.gz && \
	cd pkg-config-0.29.1 && \
	./configure --prefix=/usr --with-internal-glib --disable-compile-warnings --disable-host-tool && \
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
		/packages/pkg-config_0.29.1-1_amd64.deb && \
	cd / && \
	rm -rf /build/* /download/* /control/* && \
	dpkg --force-depends -i /packages/pkg-config_*.deb

# gawk
ADD control/gawk /control/gawk
RUN \
	set -x && \
	umask 022 && \
	LC_ALL=POSIX && \
	wget -O /download/gawk-4.1.4.tar.xz \
		http://ftp.gnu.org/gnu/gawk/gawk-4.1.4.tar.xz && \
	cd /build && \
	tar xf /download/gawk-4.1.4.tar.xz && \
	cd gawk-4.1.4 && \
	./configure --prefix=/usr && \
	MAKE="make -j4" make && \
	pre-root /build/gawk-root && \
	make DESTDIR=/build/gawk-root install-strip && \
	post-root /build/gawk-root && \
	cd /build/gawk-root && \
	rm -rf usr/share/info usr/share/locale usr/share/man && \
	rm -f usr/bin/gawk-4.1.4 && \
	rm -f usr/bin/awk && \
	make-deb \
		/build/gawk-deb \
		/build/gawk-root \
		/control/gawk \
		/packages/gawk_4.1.4-1_amd64.deb && \
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
	mv usr/bin/sed usr/bin/sed.sed && \
	make-deb \
		/build/sed-deb \
		/build/sed-root \
		/control/sed\
		/packages/sed_4.2.2-1_amd64.deb && \
	cd / && \
	rm -rf /build/* /download/* /control/* && \
	dpkg --force-depends -i /packages/sed_*.deb

# glibc
ADD control/glibc-all /control
RUN \
	set -x && \
	umask 022 && \
	LC_ALL=POSIX && \
	wget -O /download/glibc-2.24.tar.xz \
		http://ftp.gnu.org/gnu/glibc/glibc-2.24.tar.xz && \
	wget -O /download/glibc-2.24-fhs-1.patch \
		http://www.linuxfromscratch.org/patches/lfs/7.10/glibc-2.24-fhs-1.patch && \
	cd /build && \
	tar xf /download/glibc-2.24.tar.xz && \
	cd glibc-2.24 && \
	patch -Np1 -i /download/glibc-2.24-fhs-1.patch && \
	mkdir -p ../glibc-build && \
	cd ../glibc-build && \
	../glibc-2.24/configure \
		--prefix=/usr --disable-profile --enable-kernel=2.6.32\
		--enable-obsolete-rpc && \
	MAKE="make -j4" make && \
	pre-root /build/glibc-root && \
	mkdir -p /build/glibc-root/etc && \
	touch /build/glibc-root/etc/ld.so.conf && \
	make install_root=/build/glibc-root install && \
	rm -f /build/glibc-root/etc/ld.so.conf && \
	mkdir -p /build/glibc-root/usr/lib/locale && \
	I18NPATH=/build/glibc-2.24/localedata \
	locale/localedef --alias-file=../glibc-2.24/intl/locale.alias \
		-i ../glibc-2.24/localedata/locales/en_US -c \
		-f ../glibc-2.24/localedata/charmaps/ISO-8859-1 \
		--prefix=/build/glibc-root en_US && \
	I18NPATH=/build/glibc-2.24/localedata \
	locale/localedef --alias-file=../glibc-2.24/intl/locale.alias \
		-i ../glibc-2.24/localedata/locales/en_US -c \
		-f ../glibc-2.24/localedata/charmaps/UTF-8 \
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
	sed -i 's/^#!.*/#!\/bin\/sh/' usr/bin/ldd && \
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
		/packages/libc_2.24-1_amd64.deb && \

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
		/packages/glibc-bin_2.24-1_amd64.deb && \

	cp -a /build/glibc-root /build/libc-devel-root && \
	cd /build/libc-devel-root && \
	rm -rf etc usr/bin usr/share usr/sbin && \
	find usr/lib -name "*.so*" -delete && \
	make-deb \
		/build/libc-devel-deb \
		/build/libc-devel-root \
		/control/libc-devel \
		/packages/libc-devel_2.24-1_amd64.deb && \
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
		/packages/libz_1.2.8-2_amd64.deb && \

	cp -a /build/zlib-root /build/libz-devel-root && \
	cd /build/libz-devel-root && \
	rm -f usr/lib/*.so* && \
	make-deb \
		/build/libz-devel-deb \
		/build/libz-devel-root \
		/control/libz-devel \
		/packages/libz-devel_1.2.8-2_amd64.deb && \
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
	wget -O /download/file-5.29.tar.gz \
		ftp://ftp.astron.com/pub/file/file-5.29.tar.gz && \
	cd /build && \
	tar xf /download/file-5.29.tar.gz && \
	cd file-5.29 && \
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
		/packages/file_5.29-1_amd64.deb && \

	cp -a /build/file-root-orig /build/libmagic-root && \
	cd /build/libmagic-root && \
	rm -rf usr/include usr/share usr/bin && \
	rm -f usr/lib/*.la && \
	make-deb \
		/build/libmagic-deb \
		/build/libmagic-root \
		/control/libmagic \
		/packages/libmagic_5.29-1_amd64.deb && \

	cp -a /build/file-root-orig /build/libmagic-devel-root && \
	cd /build/libmagic-devel-root && \
	rm -rf usr/share usr/bin usr/lib/*.so* && \
	make-deb \
		/build/libmagic-devel-deb \
		/build/libmagic-devel-root \
		/control/libmagic-devel \
		/packages/libmagic-devel_5.29-1_amd64.deb && \

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
	wget -O /download/gmp-6.1.1.tar.xz \
		http://ftp.gnu.org/gnu/gmp/gmp-6.1.1.tar.xz && \
	cd /build && \
	tar xf /download/gmp-6.1.1.tar.xz && \
	cd gmp-6.1.1 && \
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
		/packages/libgmp_6.1.1-1_amd64.deb && \

	cp -a /build/gmp-root /build/libgmp-devel-root && \
	cd /build/libgmp-devel-root && \
	rm -f usr/lib/*.so* && \
	make-deb \
		/build/libgmp-devel-deb \
		/build/libgmp-devel-root \
		/control/libgmp-devel \
		/packages/libgmp-devel_6.1.1-1_amd64.deb && \

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
	wget -O /download/mpfr-3.1.4.tar.xz \
		http://www.mpfr.org/mpfr-3.1.4/mpfr-3.1.4.tar.xz && \
	cd /build && \
	tar xf /download/mpfr-3.1.4.tar.xz && \
	cd mpfr-3.1.4 && \
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
		/packages/libmpfr_3.1.4-1_amd64.deb && \

	cp -a /build/mpfr-root /build/libmpfr-devel-root && \
	cd /build/libmpfr-devel-root && \
	rm -f usr/lib/*.so* && \
	make-deb \
		/build/libmpfr-devel-deb \
		/build/libmpfr-devel-root \
		/control/libmpfr-devel \
		/packages/libmpfr-devel_3.1.4-1_amd64.deb && \

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
		/packages/libmpc_1.0.3-2_amd64.deb && \

	cp -a /build/mpc-root /build/libmpc-devel-root && \
	cd /build/libmpc-devel-root && \
	rm -f usr/lib/*.so* && \
	make-deb \
		/build/libmpc-devel-deb \
		/build/libmpc-devel-root \
		/control/libmpc-devel \
		/packages/libmpc-devel_1.0.3-2_amd64.deb && \

	cd / && \
        rm -rf /build/* /download/* /control/* && \
	dpkg --force-depends -P libmpc-bootstrap && \
	dpkg --force-depends -i /packages/libmpc_*.deb /packages/libmpc-devel_*.deb

# gcc
ADD control/gcc-all /control
RUN \
	set -x && \
	umask 022 && \
	LC_ALL=POSIX && \
	TARGET_PLATFORM=$(uname -m)-uc-linux-gnu && \
	wget -O /download/gcc-6.2.0.tar.bz2 \
		http://ftp.gnu.org/gnu/gcc/gcc-6.2.0/gcc-6.2.0.tar.bz2 && \
	cd /build && \
	tar xf /download/gcc-6.2.0.tar.bz2 && \
	mkdir gcc-build && \
	cd gcc-build && \
	dpkg --force-depends -P \
		libssl-devel-bootstrap && \
	SED=sed CC=gcc CXX=g++ AR=ar RANLIB=ranlib LD=ld STRIP=strip \
	CD_FOR_TARGET=gcc CXX_FOR_TARGET=g++ AR_FOR_TARGET=ar \
	RANLIB_FOR_TARGET=ranlib LD_FOR_TARGET=ld STRIP_FOR_TARGET=strip \
	../gcc-6.2.0/configure \
		--prefix=/usr --enable-languages=c,c++ --disable-multilib \
		--build="${TARGET_PLATFORM}" \
		--disable-bootstrap --with-system-zlib && \
	SED=sed CC=gcc CXX=g++ AR=ar RANLIB=ranlib LD=ld STRIP=strip \
	CD_FOR_TARGET=gcc CXX_FOR_TARGET=g++ AR_FOR_TARGET=ar \
	RANLIB_FOR_TARGET=ranlib LD_FOR_TARGET=ld STRIP_FOR_TARGET=strip \
	MAKE="make -j4" make && \
	pre-root /build/gcc-root && \
	SED=sed CC=gcc CXX=g++ AR=ar RANLIB=ranlib LD=ld STRIP=strip \
	CD_FOR_TARGET=gcc CXX_FOR_TARGET=g++ AR_FOR_TARGET=ar \
	RANLIB_FOR_TARGET=ranlib LD_FOR_TARGET=ld STRIP_FOR_TARGET=strip \
	make DESTDIR=/build/gcc-root install-strip && \
	post-root /build/gcc-root && \
	cd /build/gcc-root && \
	rm -f usr/bin/${TARGET_PLATFORM}-* && \
	for tool in c++ g++ gcc gcc-ar gcc-nm gcc-ranlib ; do ln -sf $tool usr/bin/${TARGET_PLATFORM}-$tool ; done && \
	ln -sf gcc usr/bin/${TARGET_PLATFORM}-gcc-6.2.0 && \
	ln -sv ../bin/cpp usr/lib/cpp && \
	ln -sv gcc usr/bin/cc && \
	mkdir -p usr/lib/bfd-plugins && \
	ln -sfv ../../libexec/gcc/${TARGET_PLATFORM}/6.2.0/liblto_plugin.so usr/lib/bfd-plugins/ && \
	mkdir -pv usr/share/gdb/auto-load/usr/lib && \
	mv -v usr/lib/*gdb.py usr/share/gdb/auto-load/usr/lib && \
	rm -f usr/lib/libsupc++* && \
	rm -rf usr/share/info usr/share/locale usr/share/man && \

	for pkg in libasan libatomic libcilkrts libcc1 libgcc libgomp libitm \
		liblsan libquadmath libssp libtsan libubsan ; do ( \
		mkdir -p /build/${pkg}-root/usr/lib && \
		cp -a usr/lib/${pkg}*.so* /build/${pkg}-root/usr/lib/ && \
		rm -f usr/lib/${pkg}*.so* && \
		make-deb \
			/build/${pkg}-deb \
			/build/${pkg}-root \
			/control/${pkg} \
			/packages/${pkg}_6.2.0-1_amd64.deb) ; done && \

	mkdir -p /build/libstdcxx-root/usr/lib && \
	cp -a usr/lib/libstdc++*.so* /build/libstdcxx-root/usr/lib/ && \
	rm -f usr/lib/libstdc++*.so* && \
	make-deb \
		/build/libstdcxx-deb \
		/build/libstdcxx-root \
		/control/libstdcxx \
		/packages/libstdcxx_6.2.0-1_amd64.deb && \

	make-deb \
		/build/gcc-deb \
		/build/gcc-root \
		/control/gcc \
		/packages/gcc_6.2.0-1_amd64.deb && \

	cd / && \
	rm -rf /build/* /download/* /control/* && \
	for pkg in libasan libatomic libcilkrts libgcc libgomp libitm \
		liblsan libquadmath libssp libstdcxx libtsan libubsan gcc ; do \
		dpkg --force-depends -P ${pkg}-bootstrap && \
		dpkg --force-depends -i /packages/${pkg}_*.deb ; done && \
	dpkg --force-depends -i /packages/libcc1_*.deb && \
	dpkg --force-depends -i /bootstrap/libssl-devel-bootstrap_*.deb && \
	echo 'int main(){}' > dummy.c && \
	cc dummy.c -v -Wl,--verbose &> dummy.log && \
	readelf -l a.out | grep ': /lib' && \
	grep -o '/usr/lib.*/crt[1in].*succeeded' dummy.log && \
	grep -B4 '^ /usr/include' dummy.log && \
	grep 'SEARCH.*/usr/lib' dummy.log |sed 's|; |\n|g' && \
	grep "/lib.*/libc.so.6 " dummy.log && \
	grep found dummy.log && \
	rm -v dummy.c a.out dummy.log

# m4
ADD control/m4 /control/m4
RUN \
	set -x && \
	umask 022 && \
	LC_ALL=POSIX && \
	wget -O /download/m4-1.4.17.tar.xz \
		http://ftp.gnu.org/gnu/m4/m4-1.4.17.tar.xz && \
	cd /build && \
	tar xf /download/m4-1.4.17.tar.xz && \
	cd m4-1.4.17 && \
	./configure --prefix=/usr && \
	MAKE="make -j4" make && \
	pre-root /build/m4-root && \
	make DESTDIR=/build/m4-root install && \
	cd /build/m4-root && \
	rm -rf usr/share && \
	(strip --strip-unneeded usr/bin/* || true) && \
	post-root /build/m4-root && \
	make-deb \
		/build/m4-deb \
		/build/m4-root \
		/control/m4 \
		/packages/m4_1.4.17-1_amd64.deb && \
	cd / && \
	rm -rf /build/* /download/* /control/* && \
	dpkg --force-depends -P m4-bootstrap && \
	dpkg --force-depends -i /packages/m4_*.deb

# patch
ADD control/patch /control/patch
RUN \
	set -x && \
	umask 022 && \
	LC_ALL=POSIX && \
	wget -O /download/patch-2.7.5.tar.xz \
		http://ftp.gnu.org/gnu/patch/patch-2.7.5.tar.xz && \
	cd /build && \
	tar xf /download/patch-2.7.5.tar.xz && \
	cd patch-2.7.5 && \
	./configure --prefix=/usr && \
	MAKE="make -j4" make && \
	pre-root /build/patch-root && \
	make DESTDIR=/build/patch-root install && \
	cd /build/patch-root && \
	rm -rf usr/share && \
	(strip --strip-unneeded usr/bin/* || true) && \
	mv usr/bin/patch usr/bin/patch.patch && \
	post-root /build/patch-root && \
	make-deb \
		/build/patch-deb \
		/build/patch-root \
		/control/patch \
		/packages/patch_2.7.5-1_amd64.deb && \
	cd / && \
        rm -rf /build/* /download/* /control/* && \
	dpkg --force-depends -P patch-bootstrap && \
	dpkg --force-depends -i /packages/patch_*.deb

# busybox
ADD control/busybox control/busybox
RUN \
	set -x && \
	umask 022 && \
	LC_ALL=POSIX && \
        wget -O /download/busybox-1.25.1.tar.bz2 \
		http://www.busybox.net/downloads/busybox-1.25.1.tar.bz2 && \
	cd /build && \
	tar xf /download/busybox-1.25.1.tar.bz2 && \
	cd busybox-1.25.1 && \
	confs=' \
		CONFIG_INSTALL_NO_USR \
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
	mkdir -p /build/busybox-root/usr/bin /build/busybox-root/usr/share/busybox/libexec && \
	cp -a _install/bin/busybox /build/busybox-root/usr/share/busybox/libexec/busybox && \
	cd /build/busybox-root && \
	ln -sfv busybox usr/share/busybox/libexec/sh && \
	chmod 4755 /build/busybox-root/usr/share/busybox/libexec/busybox && \
	make-deb \
		/build/busybox-deb \
		/build/busybox-root \
		/control/busybox \
		/packages/busybox_1.25.1-1_amd64.deb && \
	cp -a /usr/bin/busybox /build/busybox.temp && \
	ln -sfv /build/busybox.temp /build/dpkg && \
	ln -sfv /build/busybox.temp /build/cp && \
	ln -sfv /build/busybox.temp /build/ln && \
	ln -sfv /build/busybox.temp /build/ls && \
	dpkg --force-depends -P busybox-bootstrap && \
	/build/cp -a /build/busybox.temp /usr/bin/busybox && \
	/build/ln -sfv /usr/bin/busybox /usr/bin/sh && \
	/build/dpkg --force-depends -i /packages/busybox_*.deb && \
	dpkg --force-depends -i /packages/binutils_*.deb && \
	dpkg --force-depends -i /packages/patch_*.deb && \
	dpkg --force-depends -i /packages/sed_*.deb && \
	dpkg --force-depends -i /packages/gawk_*.deb && \

	cd / && \
	rm -rf /build/* /download/* /control/*

# bzip2
ADD control/bzip2-all control
RUN \
	set -x && \
	umask 022 && \
	LC_ALL=POSIX && \
        wget -O /download/bzip2-1.0.6.tar.gz \
		http://www.bzip.org/1.0.6/bzip2-1.0.6.tar.gz && \
	cd /build && \
	tar xf /download/bzip2-1.0.6.tar.gz && \
	cd bzip2-1.0.6 && \
	sed -i 's@\(ln -s -f \)$(PREFIX)/bin/@\1@' Makefile && \
	sed -i "s@(PREFIX)/man@(PREFIX)/share/man@g" Makefile && \
	pre-root /build/bzip2-base-root && \
	make -f Makefile-libbz2_so && \
	make clean && \
	MAKE="make -j4" make && \
	make PREFIX=/build/bzip2-base-root/usr install && \
	cp -v bzip2-shared /build/bzip2-base-root/usr/bin/bzip2 && \
	cp -av libbz2.so* /build/bzip2-base-root/usr/lib/ && \
	post-root /build/bzip2-base-root && \
	cd /build/bzip2-base-root && \
	rm -rf usr/share && \
	ln -sv libbz2.so.1.0 usr/lib/libbz2.so && \
	rm -f usr/bin/bunzip2 usr/bin/bzcat && \
	ln -sv bzip2 usr/bin/bunzip2 && \
	ln -sv bzip2 usr/bin/bzcat && \
	(strip --strip-unneeded usr/bin/* || true) && \

	cp -a /build/bzip2-base-root /build/bzip2-root && \
	cd /build/bzip2-root && \
	rm -rf usr/lib usr/include && \
	mv usr/bin/bzcat usr/bin/bzcat.bzip2 && \
	mv usr/bin/bunzip2 usr/bin/bunzip2.bzip2 && \
	mv usr/bin/bzip2 usr/bin/bzip2.bzip2 && \
	mv usr/bin/bzip2recover usr/bin/bzip2recover.bzip2 && \
	make-deb \
		/build/bzip2-deb \
		/build/bzip2-root \
		/control/bzip2 \
		/packages/bzip2_1.0.6-1_amd64.deb && \

	cp -a /build/bzip2-base-root /build/libbz2-root && \
	cd /build/libbz2-root && \
	rm -rf usr/bin usr/include && \
	rm -f usr/lib/*.a && \
	make-deb \
		/build/libbz2-deb \
		/build/libbz2-root \
		/control/libbz2 \
		/packages/libbz2_1.0.6-1_amd64.deb && \

	cp -a /build/bzip2-base-root /build/libbz2-devel-root && \
	cd /build/libbz2-devel-root && \
	rm -rf usr/bin && \
	rm -f usr/lib/*.so* && \
	make-deb \
		/build/libbz2-devel-deb \
		/build/libbz2-devel-root \
		/control/libbz2-devel \
		/packages/libbz2-devel_1.0.6-1_amd64.deb && \

	cd / && \
	rm -rf /build/* /download/* /control/* && \
	dpkg --force-depends -i \
		/packages/libbz2_*.deb /packages/libbz2-devel_*.deb /packages/bzip2_*.deb

# perl
ADD control/perl /control/perl
RUN \
	set -x && \
	umask 022 && \
	LC_ALL=POSIX && \
        wget -O /download/perl-5.24.0.tar.bz2 \
		http://www.cpan.org/src/5.0/perl-5.24.0.tar.bz2 && \
	cd /build && \
	tar xf /download/perl-5.24.0.tar.bz2 && \
	cd perl-5.24.0 && \
	export BUILD_ZLIB=False && \
	export BUILD_BZIP2=0 && \
	sh Configure -des -Dprefix=/usr -Dvendorprefix=/usr \
		-Dman1dir=/usr/share/man/man1 \
		-Dman3dir=/usr/share/man/man3 \
		-Dpager="/usr/bin/less -isR" \
		-Duseshrplib && \
	MAKE="make -j4" make && \
	pre-root /build/perl-root && \
	make DESTDIR=/build/perl-root install-strip && \
        unset BUILD_ZLIB BUILD_BZIP2 && \
	post-root /build/perl-root && \
	cd /build/perl-root && \
	rm -rf usr/share && \
	mv usr/bin/shasum usr/bin/shasum.perl && \
	make-deb \
		/build/perl-deb \
		/build/perl-root \
		/control/perl \
		/packages/perl_5.24.0-1_amd64.deb && \

	cd / && \
	rm -rf /build/* /download/* /control/* && \
	dpkg --force-depends -i /packages/perl_*.deb

# openssl
ADD control/openssl-all /control
RUN \
	set -x && \
	umask 022 && \
	LC_ALL=POSIX && \
	wget -O /download/openssl-1.0.2j.tar.gz \
		https://www.openssl.org/source/openssl-1.0.2j.tar.gz && \
	cd /build && \
	tar xf /download/openssl-1.0.2j.tar.gz && \
	cd openssl-1.0.2j && \
	./config --prefix=/usr --openssldir=/etc/ssl --libdir=lib shared zlib-dynamic && \
	sed -i 's# libcrypto.a##;s# libssl.a##' Makefile && \
	make && \
	pre-root /build/openssl-base-root && \
	make INSTALL_PREFIX=/build/openssl-base-root install && \
	cd /build/openssl-base-root && \
	rm -rf etc/ssl/man && \
	(strip --strip-debug usr/lib/* usr/lib/*/* || true) && \
	(strip --strip-unneeded usr/bin/* || true) && \
	post-root /build/openssl-base-root && \

	cp -a /build/openssl-base-root /build/libssl-root && \
	cd /build/libssl-root && \
	rm -rf etc usr/bin usr/include usr/lib/pkgconfig && \
	make-deb \
		/build/libssl-deb \
		/build/libssl-root \
		/control/libssl \
		/packages/libssl_1.0.2j-1_amd64.deb && \

	cp -a /build/openssl-base-root /build/libssl-devel-root && \
	cd /build/libssl-devel-root && \
	rm -rf etc usr/bin usr/lib/engines && \
	rm -f usr/lib/lib*  && \
	make-deb \
		/build/libssl-devel-deb \
		/build/libssl-devel-root \
		/control/libssl-devel \
		/packages/libssl-devel_1.0.2j-1_amd64.deb && \

	cp -a /build/openssl-base-root /build/openssl-root && \
	cd /build/openssl-root && \
	rm -rf usr/include usr/lib && \
	make-deb \
		/build/openssl-deb \
		/build/openssl-root \
		/control/openssl \
		/packages/openssl_1.0.2j-1_amd64.deb && \

	cd / && \
	rm -rf /build/* /download/* /control/* && \
	dpkg --force-depends -P \
		libssl-devel-bootstrap openssl-bootstrap libssl-bootstrap && \
	dpkg --force-depends -i /packages/libssl_*.deb && \
	dpkg --force-depends -i /packages/libssl-devel_*.deb && \
	dpkg --force-depends -i /packages/openssl_*.deb

# xz
add control/xz-all control
RUN \
	set -x && \
	umask 022 && \
	LC_ALL=POSIX && \
	wget -O /download/xz-5.2.2.tar.xz \
		http://tukaani.org/xz/xz-5.2.2.tar.xz && \
	cd /build && \
	tar xf /download/xz-5.2.2.tar.xz && \
	cd xz-5.2.2 && \
	./configure \
		--prefix=/usr --disable-static \
		--docdir=/usr/share/doc/xz-5.2.2 && \
	MAKE="make -j4" make && \
	pre-root /build/xz-base-root && \
	make DESTDIR=/build/xz-base-root install-strip && \
	post-root /build/xz-base-root && \
	cd /build/xz-base-root && \
	rm -rf usr/share && \

	cp -a /build/xz-base-root /build/xz-root && \
	cd /build/xz-root && \
	rm -rf usr/lib usr/include && \
	mv usr/bin/lzmadec usr/bin/lzmadec.xz && \
	mv usr/bin/lzmainfo usr/bin/lzmainfo.xz && \
	mv usr/bin/xz usr/bin/xz.xz && \
	mv usr/bin/xzdec usr/bin/xzdec.xz && \
	mv usr/bin/xzdiff usr/bin/xzdiff.xz && \
	mv usr/bin/xzgrep usr/bin/xzgrep.xz && \
	mv usr/bin/xzless usr/bin/xzless.xz && \
	mv usr/bin/xzmore usr/bin/xzmore.xz && \
	rm -f \
		usr/bin/lzcat usr/bin/lzcmp usr/bin/lzdiff \
		usr/bin/lzegrep usr/bin/lzfgrep usr/bin/lzgrep \
		usr/bin/lzless usr/bin/lzma usr/bin/lzmore \
		usr/bin/unlzma usr/bin/unxz usr/bin/xzcat \
		usr/bin/xzcmp usr/bin/xzegrep usr/bin/xzfgrep && \
	make-deb \
		/build/xz-deb \
		/build/xz-root \
		/control/xz \
		/packages/xz_5.2.2-1_amd64.deb && \
		
	cp -a /build/xz-base-root /build/liblzma-root && \
	cd /build/liblzma-root && \
	rm -rf usr/bin usr/include usr/lib/pkgconfig && \
	rm -f usr/lib/*.la && \
	make-deb \
		/build/liblzma-deb \
		/build/liblzma-root \
		/control/liblzma \
		/packages/liblzma_5.2.2-1_amd64.deb && \
		
	cp -a /build/xz-base-root /build/liblzma-devel-root && \
	cd /build/liblzma-devel-root && \
	rm -rf usr/bin && \
	rm -f usr/lib/*.so* && \
	make-deb \
		/build/liblzma-devel-deb \
		/build/liblzma-devel-root \
		/control/liblzma-devel \
		/packages/liblzma-devel_5.2.2-1_amd64.deb && \
		
	cd / && \
	rm -rf /build/* /download/* /control/* && \
	dpkg --force-depends -i \
		/packages/liblzma_*.deb \
		/packages/liblzma-devel_*.deb \
		/packages/xz_*.deb

# libarchive
ADD control/libarchive-all control
RUN \
	set -x && \
	umask 022 && \
	LC_ALL=POSIX && \
	wget -O /download/libarchive-3.2.2.tar.gz \
		http://www.libarchive.org/downloads/libarchive-3.2.2.tar.gz && \
	cd /build && \
	tar xf /download/libarchive-3.2.2.tar.gz && \
	cd libarchive-3.2.2 && \
	./configure --prefix=/usr --disable-bsdtar --disable-bsdcpio && \
	MAKE="make -j4" make && \
	pre-root /build/libarchive-base-root && \
	make DESTDIR=/build/libarchive-base-root install-strip && \
	post-root /build/libarchive-base-root && \
	cd /build/libarchive-base-root && \
	rm -rf usr/share && \

	cp -a /build/libarchive-base-root /build/libarchive-root && \
	cd /build/libarchive-root && \
	rm -rf usr/include usr/lib/pkgconfig && \
	rm -f usr/lib/*.a usr/lib/*.la && \
	make-deb \
		/build/libarchive-deb \
		/build/libarchive-root \
		/control/libarchive \
		/packages/libarchive_3.2.2-1_amd64.deb && \

	cp -a /build/libarchive-base-root /build/libarchive-devel-root && \
	cd /build/libarchive-devel-root && \
	rm -f usr/lib/*.so* && \
	make-deb \
		/build/libarchive-devel-deb \
		/build/libarchive-devel-root \
		/control/libarchive-devel \
		/packages/libarchive-devel_3.2.2-1_amd64.deb && \

	cd / && \
	rm -rf /build/* /download/* /control/* && \
	dpkg --force-depends -i \
		/packages/libarchive_*.deb /packages/libarchive-devel_*.deb

# curl
ADD control/curl-all control
RUN \
	set -x && \
	umask 022 && \
	LC_ALL=POSIX && \
	wget -O /download/curl-7.51.0.tar.bz2 \
		https://curl.haxx.se/download/curl-7.51.0.tar.bz2 && \
	cd /build && \
	tar xf /download/curl-7.51.0.tar.bz2 && \
	cd curl-7.51.0 && \
	./configure --prefix=/usr --disable-static --build=$(gcc -dumpmachine) && \
	MAKE="make -j4" make && \
	pre-root /build/curl-base-root && \
	make DESTDIR=/build/curl-base-root install-strip && \
	post-root /build/curl-base-root && \
	cd /build/curl-base-root && \
	rm -rf usr/share/man && \

	cp -a /build/curl-base-root /build/curl-root && \
	cd /build/curl-root && \
	rm -rf usr/lib usr/include usr/share usr/bin/curl-config && \
	make-deb \
		/build/curl-deb \
		/build/curl-root \
		/control/curl \
		/packages/curl_7.51.0-1_amd64.deb && \
	
	cp -a /build/curl-base-root /build/libcurl-root && \
	cd /build/libcurl-root && \
	rm -rf usr/bin usr/share usr/lib/pkgconfig usr/include && \
	rm -f usr/lib/*.la && \
	make-deb \
		/build/libcurl-deb \
		/build/libcurl-root \
		/control/libcurl \
		/packages/libcurl_7.51.0-1_amd64.deb && \
	
	cp -a /build/curl-base-root /build/libcurl-devel-root && \
	cd /build/libcurl-devel-root && \
	rm -rf usr/bin/curl && \
	rm -f usr/lib/*.so* && \
	make-deb \
		/build/libcurl-devel-deb \
		/build/libcurl-devel-root \
		/control/libcurl-devel \
		/packages/libcurl-devel_7.51.0-1_amd64.deb && \
	
	cd / && \
	rm -rf /build/* /download/* /control/* && \
	dpkg --force-depends -i \
		/packages/libcurl_*.deb \
		/packages/libcurl-devel_*.deb \
		/packages/curl_*.deb

# libgpg-error
ADD control/libgpg-error-all control
RUN \
	set -x && \
	umask 022 && \
	LC_ALL=POSIX && \
	wget -O /download/libgpg-error-1.22.tar.bz2 \
		https://www.gnupg.org/ftp/gcrypt/libgpg-error/libgpg-error-1.22.tar.bz2 && \
	cd /build && \
	tar xf /download/libgpg-error-1.22.tar.bz2 && \
	cd libgpg-error-1.22 && \
	./configure --disable-static --prefix=/usr --build=$(gcc -dumpmachine) && \
	MAKE="make -j4" make && \
	pre-root /build/libgpg-error-base-root && \
	make DESTDIR=/build/libgpg-error-base-root install-strip && \
	post-root /build/libgpg-error-base-root && \
	cd /build/libgpg-error-base-root && \
	rm -rf usr/share/info usr/share/locale usr/share/man && \
	rm -rf usr/share/common-lisp && \
	
	cp -a /build/libgpg-error-base-root /build/gpg-error-root && \
	cd /build/gpg-error-root && \
	rm -rf usr/lib usr/share usr/include usr/bin/gpg-error-config && \
	make-deb \
		/build/gpg-error-deb \
		/build/gpg-error-root \
		/control/gpg-error \
		/packages/gpg-error_1.22-1_amd64.deb && \
	
	cp -a /build/libgpg-error-base-root /build/libgpg-error-root && \
	cd /build/libgpg-error-root && \
	rm -rf usr/bin usr/share usr/include && \
	rm -f usr/lib/*.la && \
	make-deb \
		/build/libgpg-error-deb \
		/build/libgpg-error-root \
		/control/libgpg-error \
		/packages/libgpg-error_1.22-1_amd64.deb && \
	
	cp -a /build/libgpg-error-base-root /build/libgpg-error-devel-root && \
	cd /build/libgpg-error-devel-root && \
	rm -f usr/bin/gpg-error usr/lib/*.so* && \
	make-deb \
		/build/libgpg-error-devel-deb \
		/build/libgpg-error-devel-root \
		/control/libgpg-error-devel \
		/packages/libgpg-error-devel_1.22-1_amd64.deb && \

	cd / && \
	rm -rf /build/* /download/* /control/* && \
	dpkg --force-depends -i \
		/packages/libgpg-error_*.deb /packages/libgpg-error-devel_*.deb /packages/gpg-error_*.deb

# libassuan
ADD control/libassuan-all control
RUN \
	set -x && \
	umask 022 && \
	LC_ALL=POSIX && \
	wget -O /download/libassuan-2.4.3.tar.bz2 \
		https://www.gnupg.org/ftp/gcrypt/libassuan/libassuan-2.4.3.tar.bz2 && \
	cd /build && \
	tar xf /download/libassuan-2.4.3.tar.bz2 && \
	cd libassuan-2.4.3 && \
	./configure --disable-static --prefix=/usr --build=$(gcc -dumpmachine) && \
	MAKE="make -j4" make && \
	pre-root /build/libassuan-base-root && \
	make DESTDIR=/build/libassuan-base-root install-strip && \
	post-root /build/libassuan-base-root && \
	cd /build/libassuan-base-root && \
	rm -rf usr/share/info && \

	cp -a /build/libassuan-base-root /build/libassuan-root && \
	cd /build/libassuan-root && \
	rm -rf usr/bin usr/include usr/share && \
	rm -f usr/lib/*.la && \
	make-deb \
		/build/libassuan-deb \
		/build/libassuan-root \
		/control/libassuan \
		/packages/libassuan_2.4.3-1_amd64.deb && \

	cp -a /build/libassuan-base-root /build/libassuan-devel-root && \
	cd /build/libassuan-devel-root && \
	rm -f usr/lib/*.so* && \
	make-deb \
		/build/libassuan-devel-deb \
		/build/libassuan-devel-root \
		/control/libassuan-devel \
		/packages/libassuan-devel_2.4.3-1_amd64.deb && \
	
	cd / && \
	rm -rf /build/* /download/* /control/* && \
	dpkg --force-depends -i \
		/packages/libassuan_*.deb /packages/libassuan-devel_*.deb

# gpgme
ADD control/gpgme-all control
RUN \
	set -x && \
	umask 022 && \
	LC_ALL=POSIX && \
	wget -O /download/gpgme-1.7.1.tar.bz2 \
		https://www.gnupg.org/ftp/gcrypt/gpgme/gpgme-1.7.1.tar.bz2 && \
	cd /build && \
	tar xf /download/gpgme-1.7.1.tar.bz2 && \
	cd gpgme-1.7.1 && \
	./configure --disable-static --prefix=/usr --build=$(gcc -dumpmachine) && \
	MAKE="make -j4" make && \
	pre-root /build/gpgme-base-root && \
	make DESTDIR=/build/gpgme-base-root install-strip && \
	post-root /build/gpgme-base-root && \
	cd /build/gpgme-base-root && \
	rm -rf usr/share/info usr/share/common-lisp && \

	cp -a /build/gpgme-base-root /build/gpgme-root && \
	cd /build/gpgme-root && \
	rm -rf usr/bin/gpgme-config usr/lib usr/include usr/share && \
	make-deb \
		/build/gpgme-deb \
		/build/gpgme-root \
		/control/gpgme \
		/packages/gpgme_1.7.1-1_amd64.deb && \

	cp -a /build/gpgme-base-root /build/libgpgme-root && \
	cd /build/libgpgme-root && \
	rm -rf usr/bin usr/include usr/share && \
	rm -f usr/lib/*.la && \
	make-deb \
		/build/libgpgme-deb \
		/build/libgpgme-root \
		/control/libgpgme \
		/packages/libgpgme_1.7.1-1_amd64.deb && \

	cp -a /build/gpgme-base-root /build/libgpgme-devel-root && \
	cd /build/libgpgme-devel-root && \
	rm -rf usr/bin/gpgme-tool && \
	rm -f usr/lib/*.so* && \
	make-deb \
		/build/libgpgme-devel-deb \
		/build/libgpgme-devel-root \
		/control/libgpgme-devel \
		/packages/libgpgme-devel_1.7.1-1_amd64.deb && \

	cd / && \
	rm -rf /build/* /download/* /control/* && \
	dpkg --force-depends -i \
		/packages/libgpgme_*.deb /packages/libgpgme-devel_*.deb /packages/gpgme_*.deb

# autoconf
ADD control/autoconf /control/autoconf
RUN \
	set -x && \
	umask 022 && \
	LC_ALL=POSIX && \
	wget -O /download/autoconf-2.69.tar.xz \
		http://ftp.gnu.org/gnu/autoconf/autoconf-2.69.tar.xz && \
	cd /build && \
	tar xf /download/autoconf-2.69.tar.xz && \
	cd autoconf-2.69 && \
	./configure --prefix=/usr --build=$(gcc -dumpmachine) && \
	MAKE="make -j4" make && \
	pre-root /build/autoconf-root && \
	make DESTDIR=/build/autoconf-root install-strip && \
	post-root /build/autoconf-root && \
	cd /build/autoconf-root && \
	rm -rf usr/share/man usr/share/info && \
	make-deb \
		/build/autoconf-deb \
		/build/autoconf-root \
		/control/autoconf \
		/packages/autoconf_2.69-1_all.deb && \
	cd / && \
	rm -rf /build/* /download/* /control/* && \
	dpkg --force-depends -i \
		/packages/autoconf_*.deb

# automake
ADD control/automake /control/automake
RUN \
	set -x && \
	umask 022 && \
	LC_ALL=POSIX && \
	wget -O /download/automake-1.15.tar.xz \
		http://ftp.gnu.org/gnu/automake/automake-1.15.tar.xz && \
	cd /build && \
	tar xf /download/automake-1.15.tar.xz && \
	cd automake-1.15 && \
	./configure --prefix=/usr --build=$(gcc -dumpmachine) && \
	MAKE="make -j4" make && \
	pre-root /build/automake-root && \
	make DESTDIR=/build/automake-root install-strip && \
	post-root /build/automake-root && \
	cd /build/automake-root && \
	rm -rf usr/share/man usr/share/info usr/share/doc && \
	rm -f usr/bin/aclocal usr/bin/automake && \
	ln -sf aclocal-1.15 usr/bin/aclocal && \
	ln -sf automake-1.15 usr/bin/automake && \
	make-deb \
		/build/automake-deb \
		/build/automake-root \
		/control/automake \
		/packages/automake_1.15-1_all.deb && \
	cd / && \
	rm -rf /build/* /download/* /control/* && \
	dpkg --force-depends -i \
		/packages/automake_*.deb

# libtool
ADD control/libtool /control/libtool
RUN \
	set -x && \
	umask 022 && \
	LC_ALL=POSIX && \
	wget -O /download/libtool-2.4.6.tar.xz \
		http://ftp.gnu.org/gnu/libtool/libtool-2.4.6.tar.xz && \
	cd /build && \
	tar xf /download/libtool-2.4.6.tar.xz && \
	cd libtool-2.4.6 && \
	./configure --prefix=/usr --build=$(gcc -dumpmachine) && \
	MAKE="make -j4" make && \
	pre-root /build/libtool-root && \
	make DESTDIR=/build/libtool-root install-strip && \
	post-root /build/libtool-root && \
	cd /build/libtool-root && \
	rm -rf usr/share/man usr/share/info && \
	make-deb \
		/build/libtool-deb \
		/build/libtool-root \
		/control/libtool \
		/packages/libtool_2.4.6-1_amd64.deb && \
	cd / && \
	rm -rf /build/* /download/* /control/* && \
	dpkg --force-depends -i \
		/packages/libtool_*.deb

# opkg
ADD control/opkg-all /control
RUN \
	set -x && \
	umask 022 && \
	LC_ALL=POSIX && \
	wget -O /download/opkg-0.3.3.tar.gz \
		http://downloads.yoctoproject.org/releases/opkg/opkg-0.3.3.tar.gz && \
	cd /build && \
	tar xf /download/opkg-0.3.3.tar.gz && \
	cd opkg-0.3.3 && \
	libtoolize && \
	aclocal && \
	autoconf && \
	automake --add-missing && \
	./configure --prefix=/usr --build=$(gcc -dumpmachine) --disable-static && \
	MAKE="make -j4" make && \
	pre-root /build/opkg-base-root && \
	make DESTDIR=/build/opkg-base-root install-strip && \
	post-root /build/opkg-base-root && \
	cd /build/opkg-base-root && \
	rm -rf usr/share/man && \

	cp -a /build/opkg-base-root /build/opkg-root && \
	cd /build/opkg-root && \
	rm -rf usr/lib && \
	make-deb \
		/build/opkg-deb \
		/build/opkg-root \
		/control/opkg \
		/packages/opkg_0.3.3-1_amd64.deb && \

	cp -a /build/opkg-base-root /build/libopkg-root && \
	cd /build/libopkg-root && \
	rm -rf usr/bin usr/lib/pkgconfig usr/share && \
	rm -f usr/lib/*.la && \
	make-deb \
		/build/libopkg-deb \
		/build/libopkg-root \
		/control/libopkg \
		/packages/libopkg_0.3.3-1_amd64.deb && \

	cp -a /build/opkg-base-root /build/libopkg-devel-root && \
	cd /build/libopkg-devel-root && \
	rm -rf usr/bin usr/share && \
	rm -f usr/lib/*.so* && \
	make-deb \
		/build/libopkg-devel-deb \
		/build/libopkg-devel-root \
		/control/libopkg-devel \
		/packages/libopkg-devel_0.3.3-1_amd64.deb && \

	cd / && \
	rm -rf /build/* /download/* /control/* && \
	dpkg --force-depends -i \
		/packages/libopkg_*.deb /packages/libopkg-devel_*.deb /packages/opkg_*.deb

# stage 3 final prep
ADD base-feeds.conf /etc/opkg/base-feeds.conf
RUN \
	set -x && \
	umask 022 && \
	LC_ALL=POSIX && \
	chmod 755 /etc/opkg && \
	chmod 644 /etc/opkg/base-feeds.conf && \
	opkg update && \
	mkdir -p /stage3 && \
	(opkg download base-files || true) && \
	opkg -o /stage3 --nodeps install /var/cache/opkg/base-files_*.deb && \
	mkdir -p /stage3/etc/opkg && \
	cp /etc/opkg/base-feeds.conf /stage3/etc/opkg && \
	opkg -o /stage3 --nodeps install /packages/libc_*.deb && \
	chroot /stage3 /sbin/ldconfig && \
	opkg -o /stage3 --nodeps install /packages/update-alternatives_*.deb && \
	opkg -o /stage3 --nodeps install /packages/busybox_*.deb && \
	opkg -o /stage3 --nodeps install /packages/libssl_*.deb && \
	opkg -o /stage3 --nodeps install /packages/openssl_*.deb && \
	opkg -o /stage3 --nodeps install /packages/libz_*.deb && \
	opkg -o /stage3 --nodeps install /packages/liblzma_*.deb && \
	opkg -o /stage3 --nodeps install /packages/libbz2_*.deb && \
	opkg -o /stage3 --nodeps install /packages/libarchive_*.deb && \
	opkg -o /stage3 --nodeps install /packages/libcurl_*.deb && \
	opkg -o /stage3 --nodeps install /packages/libgpg-error_*.deb && \
	opkg -o /stage3 --nodeps install /packages/libassuan_*.deb && \
	opkg -o /stage3 --nodeps install /packages/libgpgme_*.deb && \
	opkg -o /stage3 --nodeps install /packages/libopkg_*.deb && \
	opkg -o /stage3 --nodeps install /packages/opkg_*.deb && \
	chroot /stage3 /usr/share/busybox/libexec/busybox ln -sf /usr/share/busybox/libexec/busybox /usr/bin/sh && \
	for pkg in \
		base-files update-alternatives busybox libssl \
		openssl libz liblzma libbz2 libarchive libcurl libgpg-error \
		libassuan libgpgme libopkg opkg ; do ( \
			chroot /stage3 /usr/bin/opkg configure "${pkg}" \
	) ; done
	
CMD ["/bin/sh"]
