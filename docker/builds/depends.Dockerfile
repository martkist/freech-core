ARG TAG
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

# Windows
RUN apt-get install -y build-essential libtool autotools-dev automake pkg-config bsdmainutils curl nsis g++-mingw-w64-x86-64
# Set the default mingw32 g++ compiler option to posix -- very important!!!
RUN update-alternatives --config x86_64-w64-mingw32-g++ 

# macOS
RUN apt-get install -y curl librsvg2-bin libtiff-tools bsdmainutils cmake imagemagick libcap-dev libz-dev libbz2-dev python3-setuptools libtinfo5 xorriso

# build
ADD depends /depends

WORKDIR /depends/SDKs
RUN curl -O https://bitcoincore.org/depends-sources/sdks/Xcode-12.1-12A7403-extracted-SDK-with-libcxx-headers.tar.gz
RUN tar -zxf Xcode-12.1-12A7403-extracted-SDK-with-libcxx-headers.tar.gz

WORKDIR /depends
RUN make HOST=x86_64-apple-darwin16 -j3
RUN make HOST=x86_64-w64-mingw32 -j3
RUN make HOST=x86_64-pc-linux-gnu -j3

# windows
# make install DESTDIR=/mnt/c/workspace/bitcoin