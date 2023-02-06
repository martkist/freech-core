ARG TAG
FROM freech:base

ENV HOST=x86_64-w64-mingw32

RUN apt-get -y install mingw-w64 g++-mingw-w64

