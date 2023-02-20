FROM ubuntu:20.04
ARG TAG
ARG MAKEOPTS
LABEL maintainer="Martkist Developers"

RUN apt-get update
RUN apt-get upgrade -y

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC 

RUN apt-get install -y git make automake cmake curl g++-multilib libtool binutils-gold bsdmainutils pkg-config python3 patch

WORKDIR /
ADD https://api.github.com/repos/martkist/freech-core/git/refs/tags/${TAG} version.json
RUN git clone https://github.com/martkist/freech-core.git

WORKDIR /freech-core
RUN git checkout ${TAG}
RUN git submodule update --init

WORKDIR /freech-core/releases/depends
ENV HOST=x86_64-pc-linux-gnu
RUN make HOST=${HOST} ${MAKEOPTS}
ENV HOSTPREFIX=/freech-core/releases/depends/${HOST}

WORKDIR /freech-core
RUN ./autotool.sh
RUN CONFIG_SITE=${HOSTPREFIX}/share/config.site ./configure --prefix=${HOSTPREFIX} --host=${HOST} --without-boost-locale CPPFLAGS="-O2" LDFLAGS="-static -pthread"
RUN make CPPFLAGS="-DBOOST_SYSTEM_ENABLE_DEPRECATED" LDFLAGS="-static -static-libgcc -static-libstdc++ -pthread" ${MAKEOPTS}

ENV PACKAGE=freech-core-${TAG}-$HOST.tar.gz
RUN strip freechd
RUN tar -czvf $PACKAGE freechd
RUN mkdir /outputs
RUN cp $PACKAGE /outputs/