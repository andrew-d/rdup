OBJ=crawler.o rdup.o gfunc.o getdelim.o signal.o usage.o sha1.o regexp.o abspath.o link.o reverse.o protocol.o msg.o common.o names.o child.o
OBJ_TR=rdup-tr.o signal.o getdelim.o usage-tr.o entry.o link.o protocol.o msg.o crypt.o base64.o common.o
OBJ_UP=rdup-up.o entry.o usage-up.o signal.o link.o getdelim.o abspath.o rm.o fs-up.o mkpath.o protocol.o msg.o dir.o strippath.o names.o
HDR=rdup.h rdup-tr.h rdup-up.h io.h common.h entry.h
CMD=rdup rdup-tr rdup-up
SH=rdup-simple
MAN1_IN=rdup.1 rdup-tr.1 rdup-up.1
MAN7_IN=rdup-backups.7

MAN1=$(addprefix doc/, $(MAN1_IN))
MAN7=$(addprefix doc/, $(MAN7_IN))

prefix=/usr/local
exec_prefix=${prefix}
datarootdir=${prefix}/share
localedir=${datarootdir}/locale
bindir=${exec_prefix}/bin
libdir=${exec_prefix}/lib
sbindir=${exec_prefix}/sbin
mandir=${datarootdir}/man
sysconfdir=/etc
datadir=${datarootdir}/rdup

ARCHIVE_L=
SSL_L=
GCC=gcc
GLIB_CFLAGS=-I/usr/include/glib-2.0 -I/usr/lib/glib-2.0/include  
GLIB_LIBS=-lglib-2.0  
LIBS=-lssl -lpcre -larchive  -lpcre
#CFLAGS=-Wall -W -Werror -g -O2  -DHAVE_CONFIG_H -DLOCALEROOTDIR=\"${datarootdir}/locale\" -D_FILE_OFFSET_BITS=64 -D_LARGE_FILES -Os -Wpointer-arith -Wstrict-prototypes 
CFLAGS=-Wall -W -Werror -g -O2  -DHAVE_CONFIG_H -DLOCALEROOTDIR=\"${datarootdir}/locale\" -D_FILE_OFFSET_BITS=64 -D_LARGE_FILES -g -Wpointer-arith -Wstrict-prototypes 
INSTALL=./install-sh -c
INSTALL_DATA=$(INSTALL) -m 644

.PHONY:	all clean install all uninstall strip

%.o:    %.c ${HDR} 
	${GCC} ${CFLAGS} ${GLIB_CFLAGS} -c $<

ifeq (${ARCHIVE_L},no)
all:	rdup rdup-up
else
all:	rdup rdup-up rdup-tr
endif
	@chmod +x sh/rdup-simple

rdup-up: $(OBJ_UP) $(HDR)
	${GCC} ${GLIB_LIBS} ${LIBS} ${OBJ_UP} -o rdup-up

rdup-tr: $(OBJ_TR) $(HDR)
	${GCC} ${GLIB_LIBS} ${LIBS} ${OBJ_TR} -o rdup-tr

rdup:	${OBJ} ${HDR} 
	${GCC} ${GLIB_LIBS} ${LIBS} ${OBJ} -o rdup

ifeq (${ARCHIVE_L},no)
strip:	rdup rdup-up
	strip ${CMD}
else
strip:	rdup rdup-up rdup-tr 
	strip ${CMD}
endif

po:	rdup.pot 
	( cd po ; $(MAKE) -f GNUmakefile all )

rdup.pot: ${OBJ} ${OBJ_TR} ${OBJ_UP}
	xgettext --omit-header -k_ -d rdup -s -o rdup.pot *.c 

tags:   *.[ch]
	ctags *.[ch]

clean:
	rm -f *.o
	rm -f rdup.mo ${CMD}
	( cd po ; $(MAKE) -f GNUmakefile clean )

realclean: clean
	rm -rf autom4te.cache
	rm -f config.log
	rm -f config.status
	rm -f config.h
	rm -f rdup.h
	rm -f rdup-tr.h
	rm -f rdup-up.h
	rm -f rdup*.tar.bz2
	rm -f rdup*.tar.bz2.sha1
	rm -f ${MAN1}
	rm -r sh/rdup-simple
	$(MAKE) -C po realclean

distclean: 

install: all
	mkdir -p ${DESTDIR}${mandir}/man1
	mkdir -p ${DESTDIR}${datadir}
	mkdir -p ${DESTDIR}${libdir}/rdup
	for i in ${CMD}; do ${INSTALL} $$i ${DESTDIR}${bindir}/$$i ; done
	for i in ${SH}; do ${INSTALL} sh/$$i ${DESTDIR}${bindir}/$$i ; done
	for i in ${MAN1}; do [ -f $$i ] &&  ${INSTALL_DATA} $$i ${DESTDIR}${mandir}/man1/`basename $$i` ; done; exit 0
	for i in ${MAN7}; do [ -f $$i ] &&  ${INSTALL_DATA} $$i ${DESTDIR}${mandir}/man7/`basename $$i` ; done; exit 0
	$(MAKE) -C po install

uninstall:
	for i in ${CMD}; do rm -f ${DESTDIR}${bindir}/$$i ; done
	for i in ${SH}; do rm -f ${DESTDIR}${bindir}/$$i ; done
	for i in ${MAN1}; do rm -f  ${DESTDIR}${mandir}/man1/`basename $$i` ; done
	for i in ${MAN7}; do rm -f  ${DESTDIR}${mandir}/man7/`basename $$i` ; done
	$(MAKE) -C po uninstall

check:	all
	@[ -d testlogs ] || mkdir testlogs
	@chmod +x testsuite/rdup/rdup*helper
	runtest 
	@chmod -x testlogs/rdup.log