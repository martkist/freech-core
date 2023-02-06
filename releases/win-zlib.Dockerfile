ARG TAG
FROM freech:win-base

RUN wget -q --no-check-certificate  https://www.zlib.net/fossils/zlib-1.2.8.tar.gz
RUN echo "36658cb768a54c1d4dec43c3116c27ed893e88b02ecfcb44f2166f9c0b7f2a0d  zlib-1.2.8.tar.gz" | shasum -c

WORKDIR $BUILDDIR
RUN tar xzf $INDIR/zlib-1.2.8.tar.gz

WORKDIR zlib-1.2.8
RUN CROSS_PREFIX=$HOST- ./configure --prefix=$INSTALLPREFIX --static
RUN make
RUN make install