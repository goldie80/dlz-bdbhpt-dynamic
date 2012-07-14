# for building the dlz_bdb_dynamic driver we don't use
# the bind9 build structure as the aim is to provide an
# example that is separable from the bind9 source tree

# this means this Makefile is not portable, so the testsuite
# skips this test on platforms where it doesn't build

CFLAGS=-fPIC -g
BDB_LIBS=-ldb

all: dlz_bdbhpt_dynamic.so

dlz_bdbhpt_dynamic.so:
	$(CC) $(CFLAGS) -shared -o dlz_bdbhpt_dynamic.so dlz_bdbhpt_dynamic.c $(BDB_LIBS)

clean:
	rm -f dlz_bdbhpt_dynamic.so

install: dlz_bdbhpt_dynamic.so
	mkdir -p /usr/lib/bind9
	install dlz_bdbhpt_dynamic.so /usr/lib/bind9