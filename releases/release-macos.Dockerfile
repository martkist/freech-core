FROM ubuntu:20.04
ARG TAG
ARG MAKEOPTS
LABEL maintainer="Martkist Developers"

RUN apt-get update
RUN apt-get upgrade -y

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC 

# general
RUN apt-get install -y git make automake cmake curl g++-multilib libtool binutils-gold bsdmainutils pkg-config python3 patch

# macOS
RUN apt-get install -y curl librsvg2-bin libtiff-tools bsdmainutils cmake imagemagick libcap-dev libz-dev libbz2-dev python3-setuptools libtinfo5 xorriso

WORKDIR /
ADD https://api.github.com/repos/martkist/freech-core/git/refs/tags/${TAG} version.json
RUN git clone https://github.com/martkist/freech-core.git

WORKDIR /freech-core
RUN git checkout ${TAG}
RUN git submodule update --init

WORKDIR /freech-core/releases/depends/SDKs
RUN curl -O https://bitcoincore.org/depends-sources/sdks/Xcode-12.1-12A7403-extracted-SDK-with-libcxx-headers.tar.gz
RUN tar -zxf Xcode-12.1-12A7403-extracted-SDK-with-libcxx-headers.tar.gz

WORKDIR /freech-core/releases/depends
ENV HOST=x86_64-apple-darwin16
RUN make HOST=${HOST} ${MAKEOPTS}
ENV HOSTPREFIX=/freech-core/releases/depends/${HOST}

WORKDIR /freech-core
RUN ./autotool.sh
RUN CONFIG_SITE=${HOSTPREFIX}/share/config.site ./configure -without-boost-locale --prefix=${HOSTPREFIX} --disable-ccache --disable-maintainer-mode --disable-dependency-tracking CPPFLAGS="-Wno-narrowing -Wno-reserved-user-defined-literal" CXXFLAGS="-Wno-narrowing -Wno-reserved-user-defined-literal"
RUN make CPPFLAGS="-DBOOST_SYSTEM_ENABLE_DEPRECATED" LDFLAGS="-static -Wl,-s" ${MAKEOPTS}

ENV PACKAGE=freech-core-${TAG}-$HOST.tar.gz
RUN tar -czvf $PACKAGE freechd
RUN mkdir /outputs
RUN cp $PACKAGE /outputs/