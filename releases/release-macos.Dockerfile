ARG TAG
ARG MAKEOPTS
FROM ubuntu:20.04
LABEL maintainer="Martkist Developers"

RUN apt-get update
RUN apt-get upgrade -y

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC 

# general
RUN apt-get install -y git make automake cmake curl g++-multilib libtool binutils-gold bsdmainutils pkg-config python3 patch

# macOS
RUN apt-get install -y curl librsvg2-bin libtiff-tools bsdmainutils cmake imagemagick libcap-dev libz-dev libbz2-dev python3-setuptools libtinfo5 xorriso

ADD depends /depends

WORKDIR /depends/SDKs
RUN curl -O https://bitcoincore.org/depends-sources/sdks/Xcode-12.1-12A7403-extracted-SDK-with-libcxx-headers.tar.gz
RUN tar -zxf Xcode-12.1-12A7403-extracted-SDK-with-libcxx-headers.tar.gz

WORKDIR /depends
ENV HOST=x86_64-apple-darwin16
RUN make HOST=$HOST $MAKEOPTS 
ENV DEPENDS=/depends/$HOST

WORKDIR /
ADD https://api.github.com/repos/martkist/freech-core/git/refs/tags/${TAG} version.json
RUN git clone https://github.com/martkist/freech-core.git

WORKDIR /freech-core
RUN git checkout ${TAG}
RUN git submodule update --init

RUN ./autotool.sh
RUN CONFIG_SITE=${DEPENDS}/share/config.site ./configure -without-boost-locale --prefix=$DEPENDS --disable-ccache --disable-maintainer-mode --disable-dependency-tracking CPPFLAGS="-Wno-narrowing -Wno-reserved-user-defined-literal" CXXFLAGS="-Wno-narrowing -Wno-reserved-user-defined-literal"
RUN make CPPFLAGS="-DBOOST_SYSTEM_ENABLE_DEPRECATED" LDFLAGS="-static" $MAKEOPTS

RUN tar -czvf freech-core-$TAG-$HOST.tar.gz freechd
RUN mkdir /outputs
RUN cp freech-core-$TAG-$HOST.tar.gz /outputs/