ARG TAG
ARG MAKEOPTS
FROM freech:win-base

RUN wget -q --no-check-certificate https://www.openssl.org/source/openssl-1.1.1s.tar.gz
RUN echo "c5ac01e760ee6ff0dab61d6b2bbd30146724d063eb322180c6f18a6f74e4b6aa  openssl-1.1.1s.tar.gz" | shasum -c

WORKDIR $BUILDDIR
RUN tar xzf $INDIR/openssl-1.1.1s.tar.gz

WORKDIR openssl-1.1.1s
#ENV OPENSSL_TGT=mingw64
RUN ./Configure --cross-compile-prefix=$HOST- mingw64 no-shared no-dso --prefix=$INSTALLPREFIX --openssldir=$INSTALLPREFIX
RUN make $MAKEOPTS
RUN make install_sw