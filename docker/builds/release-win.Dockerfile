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
#RUN update-alternatives --set x86_64-w64-mingw32-g++ /usr/bin/x86_64-w64-mingw32-g++-posix

ADD depends /depends

WORKDIR /depends
RUN make HOST=x86_64-w64-mingw32 $MAKEOPTS 

ENV HOST=x86_64-w64-mingw32
ENV DEPENDS=/depends/$HOST

WORKDIR /
ADD https://api.github.com/repos/martkist/freech-core/git/refs/tags/${TAG} version.json
RUN git clone https://github.com/martkist/freech-core.git

WORKDIR /freech-core
RUN git checkout ${TAG}
RUN git submodule update --init

RUN ./autotool.sh
RUN ./configure --prefix=$DEPENDS --host=$HOST --with-libdb=$DEPENDS --with-boost=$DEPENDS --without-boost-locale --with-openssl=$DEPENDS CPPFLAGS="-O2" CXXFLAGS="-O2" LDFLAGS="-static"
RUN make CPPFLAGS="-DBOOST_SYSTEM_ENABLE_DEPRECATED" LDFLAGS="-static -static-libgcc -static-libstdc++" $MAKEOPTS
RUN strip freechd.exe

RUN mkdir /outputs
RUN cp freechd.exe /outputs/

# ARG TAG
# ARG MAKEOPTS

# FROM freech:win-boost AS boost
# FROM freech:win-db48 AS db48
# FROM freech:win-openssl AS openssl
# FROM freech:win-zlib AS zlib


# FROM ubuntu:20.04
# LABEL maintainer="Martkist Developers"

# ENV HOST=x86_64-w64-mingw32
# ENV DEPENDS=/depends/$HOST

# # dependencies
# ENV BITS=64
# ENV INDIR=/root/inputs
# ENV OUTDIR=/root/outputs
# ENV TEMPDIR=/root/tmp
# ENV BUILDDIR=/root/build
# ENV INSTALLPREFIX=/root/staging
# RUN mkdir -p $DEPENDS

# COPY --from=boost $INSTALLPREFIX/lib $DEPENDS/lib
# COPY --from=boost $INSTALLPREFIX/include $DEPENDS/include

# COPY --from=db48 $INSTALLPREFIX/lib $DEPENDS/lib
# COPY --from=db48 $INSTALLPREFIX/include $DEPENDS/include

# COPY --from=openssl $INSTALLPREFIX/lib $DEPENDS/lib
# COPY --from=openssl $INSTALLPREFIX/include $DEPENDS/include

# COPY --from=zlib $INSTALLPREFIX/lib $DEPENDS/lib
# COPY --from=zlib $INSTALLPREFIX/include $DEPENDS/include

# RUN apt-get update
# RUN apt-get upgrade -y

# ENV DEBIAN_FRONTEND=noninteractive
# ENV TZ=Etc/UTC 

# #RUN apt-get install -y git build-essential libtool autotools-dev automake pkg-config bsdmainutils curl nsis g++-mingw-w64-x86-64
# RUN apt-get install -y git build-essential libtool autotools-dev automake pkg-config bsdmainutils curl nsis mingw-w64 g++-mingw-w64

# # Set the default mingw32 g++ compiler option to posix -- see Bitcoin build docs (build-windows.md#footnote1)
# #RUN update-alternatives --set x86_64-w64-mingw32-g++ /usr/bin/x86_64-w64-mingw32-g++-posix
# #RUN update-alternatives --config x86_64-w64-mingw32-g++

# #ADD depends /depends

# #WORKDIR /depends
# # RUN make HOST=x86_64-w64-mingw32 $MAKEOPTS 

# WORKDIR /
# ADD https://api.github.com/repos/martkist/freech-core/git/refs/tags/${TAG} version.json
# RUN git clone https://github.com/martkist/freech-core.git

# WORKDIR /freech-core
# RUN git checkout ${TAG}
# RUN git submodule update --init

# RUN ./autotool.sh
# RUN ./configure --prefix=$DEPENDS --host=$HOST --with-libdb=$DEPENDS --with-boost=$DEPENDS --without-boost-locale --with-openssl=$DEPENDS CPPFLAGS="-O2" CXXFLAGS="-O2" LDFLAGS="-static"
# RUN make CPPFLAGS="-DBOOST_SYSTEM_ENABLE_DEPRECATED" LDFLAGS="-static -static-libgcc -static-libstdc++" $MAKEOPTS
# RUN strip freechd.exe

# RUN mkdir /outputs
# RUN cp freechd.exe /outputs/