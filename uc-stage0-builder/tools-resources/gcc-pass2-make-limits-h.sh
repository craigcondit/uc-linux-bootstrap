TARGET_PLATFORM=$(uname -m)-uc-linux-gnu cat gcc/limitx.h gcc/glimits.h gcc/limity.h > \
  `dirname $($TARGET_PLATFORM-gcc -print-libgcc-file-name)`/include-fixed/limits.h
