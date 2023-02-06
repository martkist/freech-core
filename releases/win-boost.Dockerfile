ARG TAG
FROM freech:win-base

RUN wget -q https://boostorg.jfrog.io/artifactory/main/release/1.71.0/source/boost_1_71_0.tar.bz2
RUN echo "d73a8da01e8bf8c7eda40b4c84915071a8c8a0df4a6734537ddde4a8580524ee  boost_1_71_0.tar.bz2" | shasum -c

WORKDIR $BUILDDIR
RUN tar --warning=no-timestamp -xjf $INDIR/boost_1_71_0.tar.bz2

WORKDIR boost_1_71_0
RUN echo "using gcc : $GCCVERSION : $HOST-g++ \
        : \
        <rc>$HOST-windres \
        <archiver>$HOST-ar \
        <cxxflags>-frandom-seed=boost1 \
        <ranlib>$HOST-ranlib \
  ;" > user-config.jam
RUN ./bootstrap.sh --without-icu
RUN ./b2 toolset=gcc binary-format=pe target-os=windows threadapi=win32 address-model=$BITS threading=multi variant=release link=static runtime-link=static --user-config=user-config.jam --without-mpi --without-python -sNO_BZIP2=1 -sNO_ZLIB=1 --layout=tagged --build-type=complete --prefix="$INSTALLPREFIX" $MAKEOPTS install