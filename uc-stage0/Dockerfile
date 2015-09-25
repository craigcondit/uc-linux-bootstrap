FROM scratch
MAINTAINER ccondit@randomcoder.com
ADD uc-stage0.tar /
ADD uc-stage0-tools.tar /tools/

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
		
CMD ["/bin/sh"]
