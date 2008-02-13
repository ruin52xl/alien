
all: src/alien.so src/alien/struct.so tests/libalientest.so

src/alien.o: src/alien.c libffi/include/ffi.h
	$(CC) -c $(CFLAGS) -Ilibffi/include -o src/alien.o src/alien.c

libffi/include/ffi.h:
	cat executables | xargs chmod +x
	cd libffi && ./configure --disable-shared CC=gcc

libffi/Makefile:
	cat executables | xargs chmod +x
	cd libffi && ./configure --disable-shared CC=gcc

libffi/.libs/libffi.a: libffi/Makefile
	cd libffi && make CC=gcc

src/alien.so: src/alien.o libffi/.libs/libffi.a
	export MACOSX_DEPLOYMENT_TARGET=10.3; $(LD) $(LIB_OPTION) -o src/alien.so src/alien.o -Llibffi/.libs -lffi

src/alien/struct.so: src/alien/struct.o 
	export MACOSX_DEPLOYMENT_TARGET=10.3; $(LD) $(LIB_OPTION) -o src/alien/struct.so src/alien/struct.o

install: src/alien.so src/alien/struct.so
	cp src/alien.so $(LUA_LIBDIR)
	mkdir -p $(LUA_LIBDIR)/alien
	cp src/alien/struct.so $(LUA_LIBDIR)/alien
	chmod +x src/constants
	cp src/constants $(BIN_DIR)/
	cp -r tests $(PREFIX)/
	cp -r samples $(PREFIX)/
	cp -r doc $(PREFIX)/

clean:
	find . -name "*.so" -o -name "*.o" | xargs rm -f

upload:
	darcs dist -d alien-current
	ncftpput -u mascarenhas ftp.luaforge.net alien/htdocs alien-current.tar.gz
	ncftpput -u mascarenhas ftp.luaforge.net alien/htdocs doc/index.html

tests/libalientest.so: tests/alientest.c
	$(CC) $(LIB_OPTION) $(CFLAGS) -o tests/libalientest.so tests/alientest.c

test:
	cd tests && lua -l luarocks.require test_alien.lua
