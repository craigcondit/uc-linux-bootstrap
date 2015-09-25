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
	mkdir -p /chroot/tools && \
	ln -sv /chroot/tools / && \
	curl -ksSL http://ftp.gnu.org/gnu/binutils/binutils-2.25.1.tar.bz2 > \
		/download/binutils-2.25.1.tar.bz2 && \
	cd /build && \
	tar xf /download/binutils-2.25.1.tar.bz2 && \
	mkdir binutils-build && \
	cd binutils-build && \
	../binutils-2.25.1/configure \
		--prefix=/tools --with-sysroot=/chroot --with-lib-path=/tools/lib \
		--target="$TARGET_PLATFORM" --disable-nls --disable-werror && \
	MAKE="make -j4" make && \
	mkdir -p /tools/lib && \
	ln -sv lib /tools/lib64 && \
	make install && \
	cd /build && \
	rm -rf binutils-2.25.1 binutils-build

# gcc (stage 1)
ADD tools-resources/gcc-fix-paths.sh /build/gcc-fix-paths.sh
RUN \
	set -xe && \
	umask 022 && \
	LC_ALL=POSIX && \
	TARGET_PLATFORM=$(uname -m)-uc-linux-gnu && \
	PATH=/tools/bin:/bin:/usr/bin && \
	curl -ksSL http://ftp.gnu.org/gnu/gcc/gcc-5.2.0/gcc-5.2.0.tar.bz2 > \
		/download/gcc-5.2.0.tar.bz2 && \
	curl -ksSL http://www.mpfr.org/mpfr-3.1.3/mpfr-3.1.3.tar.xz > \
		/download/mpfr-3.1.3.tar.xz && \
	curl -ksSL http://ftp.gnu.org/gnu/gmp/gmp-6.0.0a.tar.xz > \
		/download/gmp-6.0.0a.tar.xz && \
	curl -ksSL http://www.multiprecision.org/mpc/download/mpc-1.0.3.tar.gz > \
		/download/mpc-1.0.3.tar.gz && \
	cd /build && \
	tar xf /download/gcc-5.2.0.tar.bz2 && \
	cd gcc-5.2.0 && \
	tar xf /download/mpfr-3.1.3.tar.xz && \
	mv -f mpfr-3.1.3 mpfr && \
	tar xf /download/gmp-6.0.0a.tar.xz && \
	mv -f gmp-6.0.0 gmp && \
	tar xf /download/mpc-1.0.3.tar.gz && \
	mv -f mpc-1.0.3 mpc && \
	bash /build/gcc-fix-paths.sh && \
	mkdir -p /build/gcc-build && \
	cd ../gcc-build && \
	../gcc-5.2.0/configure \
		--target=$TARGET_PLATFORM --prefix=/tools \
		--with-glibc-version=2.11 --with-sysroot=/chroot \
		--with-newlib --without-headers --with-local-prefix=/tools \
		--with-native-system-header-dir=/tools/include --disable-nls \
		--disable-shared --disable-multilib --disable-decimal-float \
		--disable-threads --disable-libatomic --disable-libgomp \
		--disable-libquadmath --disable-libssp --disable-libvtv \
		--disable-libstdcxx --enable-languages=c,c++ && \
	MAKE="make -j4" make && make install && \
	cd /build && \
	rm -rf gcc-5.2.0 gcc-build gcc-fix-paths.sh

# linux headers
RUN \
	set -xe && \
	umask 022 && \
	LC_ALL=POSIX && \
	TARGET_PLATFORM=$(uname -m)-uc-linux-gnu && \
	PATH=/tools/bin:/bin:/usr/bin && \
	curl -ksSL https://www.kernel.org/pub/linux/kernel/v4.x/linux-4.2.1.tar.xz >  \
		/download/linux-4.2.1.tar.xz && \
	cd /build && \
	tar Pxf /download/linux-4.2.1.tar.xz && \
	cd linux-4.2.1 && \
	make mrproper && \
	make INSTALL_HDR_PATH=dest headers_install && \
	cp -rv dest/include/* /tools/include && \
	cd /build && \
	rm -rf linux-4.2.1

# glibc
RUN \
	set -xe && \
	umask 022 && \
	LC_ALL=POSIX && \
	TARGET_PLATFORM=$(uname -m)-uc-linux-gnu && \
	PATH=/tools/bin:/bin:/usr/bin && \
	curl -ksSL http://ftp.gnu.org/gnu/glibc/glibc-2.22.tar.xz > \
		/download/glibc-2.22.tar.xz && \
	curl -ksSL http://www.linuxfromscratch.org/patches/lfs/systemd/glibc-2.22-upstream_i386_fix-1.patch > \
		/download/libc-2.22-upstream_i386_fix-1.patch && \
        cd /build && \
        tar xf /download/glibc-2.22.tar.xz && \
	cd glibc-2.22 && \
	patch -Np1 -i /download/libc-2.22-upstream_i386_fix-1.patch && \
	mkdir -p ../glibc-build && \
	cd ../glibc-build && \
	../glibc-2.22/configure \
		--prefix=/tools --host=$TARGET_PLATFORM \
		--build=$(../glibc-2.22/scripts/config.guess) \
		--disable-profile --enable-kernel=2.6.32 --enable-obsolete-rpc \
		--with-headers=/tools/include libc_cv_forced_unwind=yes \
		libc_cv_ctors_header=yes libc_cv_c_cleanup=yes && \
	MAKE="make -j4" make && \
	make install && \
	echo 'main(){}' > dummy.c && \
	${TARGET_PLATFORM}-gcc dummy.c && \
	readelf -l a.out | grep ': /tools' && \
	rm -v dummy.c a.out && \
	cd /build && \
	rm -rf glibc-2.22 glibc-build

CMD ["/bin/bash"]
