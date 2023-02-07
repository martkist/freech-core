FROM ubuntu:20.04
ARG TAG
ARG MAKEOPTS
LABEL maintainer="Martkist Developers"

RUN apt-get update
RUN apt-get upgrade -y

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC 

RUN apt-get install -y git build-essential libtool autotools-dev automake pkg-config bsdmainutils curl nsis g++-mingw-w64-x86-64

ADD depends /depends

WORKDIR /depends
ENV HOST=x86_64-w64-mingw32
RUN make HOST=$HOST ${MAKEOPTS}
ENV DEPENDS=/depends/$HOST

WORKDIR /
ADD https://api.github.com/repos/martkist/freech-core/git/refs/tags/${TAG} version.json
RUN git clone https://github.com/martkist/freech-core.git

WORKDIR /freech-core
RUN git checkout ${TAG}
RUN git submodule update --init

RUN ./autotool.sh
RUN ./configure --prefix=$DEPENDS --host=$HOST --with-libdb=$DEPENDS --with-boost=$DEPENDS --without-boost-locale --with-openssl=$DEPENDS CPPFLAGS="-O2" CXXFLAGS="-O2" LDFLAGS="-static"
RUN make CPPFLAGS="-DBOOST_SYSTEM_ENABLE_DEPRECATED" LDFLAGS="-static -static-libgcc -static-libstdc++" ${MAKEOPTS}

ENV PACKAGE=freech-core-${TAG}-$HOST.tar.gz
RUN strip freechd.exe
RUN tar -czvf $PACKAGE freechd.exe
RUN mkdir /outputs
RUN cp $PACKAGE /outputs/