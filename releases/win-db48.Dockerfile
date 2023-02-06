ARG TAG
ARG MAKEOPTS
FROM freech:win-base

RUN wget -q --no-check-certificate  http://download.oracle.com/berkeley-db/db-4.8.30.NC.tar.gz
RUN echo "12edc0df75bf9abd7f82f821795bcee50f42cb2e5f76a6a281b85732798364ef  db-4.8.30.NC.tar.gz" | shasum -c

WORKDIR $BUILDDIR
RUN tar xzf $INDIR/db-4.8.30.NC.tar.gz

WORKDIR db-4.8.30.NC/build_unix
RUN ../dist/configure --prefix=$INSTALLPREFIX --enable-mingw --enable-cxx --host=$HOST --disable-shared --disable-replication
RUN make $MAKEOPTS library_build
RUN make install_lib install_include