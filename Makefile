# for building the dlz_bdb_dynamic driver we don't use
# the bind9 build structure as the aim is to provide an
# example that is separable from the bind9 source tree

# this means this Makefile is not portable, so the testsuite
# skips this test on platforms where it doesn't build

CFLAGS=-fPIC -g

all: dlz_bdbhpt_dynamic.so

dlz_bdbhpt_dynamic.so: dlz_bdbhpt_dynamic.o
	$(CC) $(CFLAGS) -shared -ldb-5.1 -o dlz_bdbhpt_dynamic.so dlz_bdbhpt_dynamic.o

clean:
	rm -f dlz_bdbhpt_dynamic.o dlz_bdbhpt_dynamic.so
