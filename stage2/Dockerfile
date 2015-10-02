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

CMD ["/bin/sh"]
