ARG TAG
ARG MAKEOPTS

FROM freech:win-boost AS boost
FROM freech:win-db48 AS db48
FROM freech:win-openssl AS openssl
FROM freech:win-zlib AS zlib

FROM freech:win-base

# dependencies
ENV STAGING=$HOME/staging
RUN mkdir -p $STAGING

COPY --from=boost $INSTALLPREFIX/lib $STAGING/lib
COPY --from=boost $INSTALLPREFIX/include $STAGING/include

COPY --from=db48 $INSTALLPREFIX/lib $STAGING/lib
COPY --from=db48 $INSTALLPREFIX/include $STAGING/include

COPY --from=openssl $INSTALLPREFIX/lib $STAGING/lib
COPY --from=openssl $INSTALLPREFIX/include $STAGING/include

COPY --from=zlib $INSTALLPREFIX/lib $STAGING/lib
COPY --from=zlib $INSTALLPREFIX/include $STAGING/include

# make deterministic libs
RUN /bin/bash -c 'for LIB in $(find $STAGING -name \*.a); \
        do \
        rm -rf $TEMPDIR && mkdir $TEMPDIR && cd $TEMPDIR; \
        $HOST-ar xv $LIB | cut -b5- > /tmp/list.txt; \
        rm $LIB; \
        $HOST-ar crsD $LIB $(cat /tmp/list.txt); \
    done'

# build
WORKDIR $BUILDDIR
ADD https://api.github.com/repos/martkist/freech-core/git/refs/tags/${TAG} version.json
RUN git clone https://github.com/martkist/freech-core.git

WORKDIR freech-core
RUN git checkout ${TAG}

RUN OPTFLAGS='-O2 '

RUN export PATH=$STAGING/host/bin:$PATH

RUN git submodule update --init
RUN ./autotool.sh
RUN ./configure --bindir=$OUTDIR --prefix=$STAGING --host=$HOST --with-boost=$STAGING --with-openssl=$STAGING CPPFLAGS="-I$STAGING/include ${OPTFLAGS}" LDFLAGS="-L$STAGING/lib ${OPTFLAGS}" CXXFLAGS="${OPTFLAGS}" --without-boost-locale
RUN make CPPFLAGS="-DBOOST_SYSTEM_ENABLE_DEPRECATED" LDFLAGS="-static -static-libgcc -static-libstdc++" $MAKEOPTS
RUN strip freechd.exe
RUN cp -f freechd.exe $OUTDIR/
RUN unset LD_PRELOAD
RUN unset FAKETIME