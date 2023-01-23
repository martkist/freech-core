#
# Dockerfile for building Freech peer-to-peer freedom of speech
#
FROM ubuntu:20.04

# Install freech-core
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive  apt-get install -y iproute2 git autoconf libtool build-essential libboost-all-dev libssl-dev libdb++-dev libminiupnpc-dev automake && apt-get clean
RUN git clone https://github.com/martkist/freech-core.git
COPY . /freech-core
RUN cd freech-core && \
    ./bootstrap.sh && \
    make

# Install freech-html
RUN git clone https://github.com/martkist/freech-html.git /freech-html

# Configure HOME directory
# and persist freech data directory as a volume
ENV HOME /root
VOLUME /root/.freech

# Run freechd by default
ENTRYPOINT ["/freech-core/docker-entrypoint.sh"]
EXPOSE 28332
