ARG TAG
FROM ubuntu:20.04
LABEL maintainer="Martkist Developers"

RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get -y install tzdata
RUN apt-get -y install perl wget pciutils build-essential git lsb-release sudo
RUN apt-get -y install faketime zip unzip autoconf libtool automake pkg-config bsdmainutils

ARG MAKEOPTS
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