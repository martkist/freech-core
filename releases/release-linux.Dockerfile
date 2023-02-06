ARG TAG
ARG MAKEOPTS
FROM ubuntu:20.04
LABEL maintainer="Martkist Developers"

RUN apt-get update
RUN apt-get upgrade -y

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC 

# general
RUN apt-get install -y git

# Linux
RUN apt-get install -y make automake cmake curl g++-multilib libtool binutils-gold bsdmainutils pkg-config python3 patch

# build
ADD depends /depends

WORKDIR /depends
ENV HOST=x86_64-pc-linux-gnu
RUN make HOST=$HOST $MAKEOPTS
ENV DEPENDS=/depends/x86_64-pc-linux-gnu

WORKDIR /
ADD https://api.github.com/repos/martkist/freech-core/git/refs/tags/${TAG} version.json
RUN git clone https://github.com/martkist/freech-core.git

WORKDIR /freech-core
RUN git checkout ${TAG}
RUN git submodule update --init

RUN ./autotool.sh
RUN ./configure --prefix=$DEPENDS --with-libdb=$DEPENDS --host=$HOST --without-boost-locale --with-openssl=$DEPENDS CPPFLAGS="-O2" CXXFLAGS="-O2" LDFLAGS="-static"
RUN make CPPFLAGS="-DBOOST_SYSTEM_ENABLE_DEPRECATED" LDFLAGS="-static -static-libgcc -static-libstdc++" $MAKEOPTS

RUN tar -czvf freech-core-$TAG-$HOST.tar.gz freechd
RUN mkdir /outputs
RUN cp freech-core-$TAG-$HOST.tar.gz /outputs/