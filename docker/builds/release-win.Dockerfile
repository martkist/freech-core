ARG TAG
ARG MAKEOPTS
FROM ubuntu:20.04
LABEL maintainer="Martkist Developers"

RUN apt-get update
RUN apt-get upgrade -y

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC 

RUN apt-get install -y git build-essential libtool autotools-dev automake pkg-config bsdmainutils curl nsis g++-mingw-w64-x86-64

# Set the default mingw32 g++ compiler option to posix -- see Bitcoin build docs (build-windows.md#footnote1)
RUN update-alternatives --set x86_64-w64-mingw32-g++ /usr/bin/x86_64-w64-mingw32-g++-posix

ADD depends /depends

WORKDIR /depends
RUN make HOST=x86_64-w64-mingw32 $MAKEOPTS

WORKDIR /
ADD https://api.github.com/repos/martkist/freech-core/git/refs/tags/${TAG} version.json
RUN git clone https://github.com/martkist/freech-core.git

WORKDIR /freech-core
RUN git checkout ${TAG}

ENV HOST=x86_64-w64-mingw32
ENV DEPENDS=/depends/$HOST

RUN git submodule update --init
RUN ./autotool.sh
RUN ./configure --prefix=$DEPENDS --host=$HOST --with-boost=$DEPENDS --with-openssl=$DEPENDS CPPFLAGS="-O2" CXXFLAGS="-O2" --without-boost-locale
RUN make CPPFLAGS="-DBOOST_SYSTEM_ENABLE_DEPRECATED" LDFLAGS="-static -static-libgcc -static-libstdc++" $MAKEOPTS
RUN strip freechd.exe
RUN cp -f freechd.exe $OUTDIR/
RUN unset LD_PRELOAD
RUN unset FAKETIME