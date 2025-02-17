#
# Makefile for sash
#
# The HAVE_GZIP definition adds the -gzip and -gunzip commands.
# The HAVE_LINUX_ATTR definition adds the -chattr and -lsattr commands.
# The HAVE_LINUX_CHROOT definition adds the -chroot command.
# The HAVE_LINUX_PIVOT definition adds the -pivot_root command.
# The HAVE_LINUX_LOSETUP definition adds the -losetup command.
# The HAVE_LINUX_MOUNT definition makes -mount and -umount work on Linux.
# The HAVE_BSD_MOUNT definition makes -mount and -umount work on BSD.
# The MOUNT_TYPE definition sets the default file system type for -mount.
#
# Note that the linker may show warnings about 'statically linked
# programs' requiring getpwnam, getpwuid, getgrnam and getgrgid.
# This is unavoidable since those routines use dynamic libraries anyway.
# Sash will still run, but if there are shared library problems then
# the user might have to be be careful when using the -chown, -chgrp,
# and -ls commands.
#

CC=gcc

HAVE_GZIP		= 0
#ifeq (Linux,$(shell uname -s))
HAVE_LINUX_ATTR		= 0
HAVE_LINUX_CHROOT	= 0
HAVE_LINUX_LOSETUP	= 0
HAVE_LINUX_PIVOT	= 0
HAVE_LINUX_MOUNT	= 0
HAVE_BSD_MOUNT		= 0
MOUNT_TYPE		= '"ext3"'
#endif
ifeq (GNU/kFreeBSD,$(shell uname -s))
HAVE_LINUX_ATTR	= 0
HAVE_LINUX_CHROOT	= 0
HAVE_LINUX_LOSETUP	= 0
HAVE_LINUX_PIVOT	= 0
HAVE_LINUX_MOUNT	= 0
HAVE_BSD_MOUNT		= 1
MOUNT_TYPE		= '"ufs"'
endif

OPT = -O0

CFLAGS = $(OPT) -Wall -Wmissing-prototypes \
	-I/sysroot/usr/include \
	-I../musl/include \
	-I../musl/arch/arm \
	-DHAVE_GZIP=$(HAVE_GZIP) \
	-DHAVE_LINUX_ATTR=$(HAVE_LINUX_ATTR) \
 	-DHAVE_LINUX_CHROOT=$(HAVE_LINUX_CHROOT) \
 	-DHAVE_LINUX_LOSETUP=$(HAVE_LINUX_LOSETUP) \
 	-DHAVE_LINUX_PIVOT=$(HAVE_LINUX_PIVOT) \
	-DHAVE_LINUX_MOUNT=$(HAVE_LINUX_MOUNT) \
	-DHAVE_BSD_MOUNT=$(HAVE_BSD_MOUNT) \
	-DMOUNT_TYPE=$(MOUNT_TYPE) \
	-march=armv7ve -mcpu=cortex-a7 -mthumb -mfpu=neon -mfloat-abi=hard

LDFLAGS = --sysroot=/sysroot -Wl,--no-undefined -nodefaultlibs -B "/sysroot/tools/gcc/" -march=armv7ve -mcpu=cortex-a7 -mthumb -mfpu=neon -mfloat-abi=hard
LIBS = -L/sysroot/usr/lib -lapplibs -lpthread -lgcc_s -lc


DESTDIR =
BINDIR = /bin
MANDIR = /usr/man


OBJS = sash.o cmds.o cmd_dd.o cmd_ed.o cmd_grep.o cmd_ls.o cmd_tar.o \
	cmd_gzip.o cmd_find.o cmd_file.o cmd_chattr.o cmd_ar.o utils.o stubs.o


sash:	$(OBJS)
	$(CC) $(LDFLAGS) -o sash $(OBJS) $(LIBS)
	strip sash

clean:
	rm -f $(OBJS) sash

install: sash
	cp sash $(DESTDIR)/$(BINDIR)/sash
	cp sash.1 $(DESTDIR)/$(MANDIR)/man1/sash.1

%.o: %.c
	$(CC) $(CFLAGS) $(DEFS) -c $<

$(OBJS):	sash.h
