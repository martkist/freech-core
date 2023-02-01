ARG TAG
ARG MAKEOPTS
FROM ubuntu:precise
LABEL maintainer="Martkist Developers"

RUN sed -i -e 's/archive.ubuntu.com/old-releases.ubuntu.com/g' /etc/apt/sources.list
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get -y install tzdata
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install perl wget pciutils build-essential git lsb-release sudo
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install faketime zip unzip autoconf libtool automake pkg-config bsdmainutils

ENV BITS=64
ENV INDIR=/root/inputs
ENV OUTDIR=/root/outputs
ENV TEMPDIR=/root/tmp
ENV BUILDDIR=/root/build
ENV INSTALLPREFIX=/root/staging

RUN mkdir -p $INDIR $OUTDIR $TEMPDIR $BUILDDIR $INSTALLPREFIX 
WORKDIR $INDIR

RUN export LD_PRELOAD=/usr/lib/faketime/libfaketime.so.1
RUN export FAKETIME="2023-01-01 00:00:00"
RUN export TZ=UTC

ENV HOST=x86_64-w64-mingw32

RUN apt-get -y install mingw-w64 g++-mingw-w64

RUN wget -q --no-check-certificate  http://download.oracle.com/berkeley-db/db-4.8.30.NC.tar.gz
RUN echo "12edc0df75bf9abd7f82f821795bcee50f42cb2e5f76a6a281b85732798364ef  db-4.8.30.NC.tar.gz" | shasum -c

WORKDIR $BUILDDIR
RUN tar xzf $INDIR/db-4.8.30.NC.tar.gz

WORKDIR db-4.8.30.NC/+build_unix
RUN ../dist/configure --prefix=$INSTALLPREFIX --enable-mingw --enable-cxx --host=$HOST --disable-shared
RUN make $MAKEOPTS library_build
RUN make install_lib install_include