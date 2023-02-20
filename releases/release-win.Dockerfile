FROM ubuntu:20.04
ARG TAG
ARG MAKEOPTS
LABEL maintainer="Martkist Developers"

RUN apt-get update
RUN apt-get upgrade -y

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC 

RUN apt-get install -y git build-essential libtool autotools-dev automake pkg-config bsdmainutils curl nsis g++-mingw-w64-x86-64

WORKDIR /
ADD https://api.github.com/repos/martkist/freech-core/git/refs/tags/${TAG} version.json
RUN git clone https://github.com/martkist/freech-core.git

WORKDIR /freech-core
RUN git checkout ${TAG}
RUN git submodule update --init

WORKDIR /freech-core/releases/depends
ENV HOST=x86_64-w64-mingw32
RUN make HOST=$HOST ${MAKEOPTS}
ENV HOSTPREFIX=/freech-core/releases/depends/${HOST}

WORKDIR /freech-core
RUN ./autotool.sh
RUN CONFIG_SITE=${HOSTPREFIX}/share/config.site ./configure --prefix=${HOSTPREFIX} --host=${HOST} --without-boost-locale CPPFLAGS="-O2" LDFLAGS="-static"
RUN make CPPFLAGS="-DBOOST_SYSTEM_ENABLE_DEPRECATED" LDFLAGS="-static -static-libgcc -static-libstdc++" ${MAKEOPTS}

ENV PACKAGE=freech-core-${TAG}-$HOST.tar.gz
RUN strip freechd.exe
RUN tar -czvf $PACKAGE freechd.exe
RUN mkdir /outputs
RUN cp $PACKAGE /outputs/