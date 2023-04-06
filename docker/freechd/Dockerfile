#
# Dockerfile for building Freech peer-to-peer freedom of speech
# base daemon only, no UI
#
FROM ubuntu:20.04
ARG TAG
ARG MAKEOPTS=-j3
LABEL maintainer="Martkist Developers"
LABEL tag=${TAG}

# Install freech-core
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive  apt-get install -y iproute2 git autoconf libtool build-essential libboost-all-dev libssl-dev libdb++-dev libminiupnpc-dev automake && apt-get clean

ADD https://api.github.com/repos/martkist/freech-core/git/refs/tags/${TAG} version.json
RUN git clone https://github.com/martkist/freech-core.git
WORKDIR /freech-core
RUN git checkout ${TAG}
RUN ./bootstrap.sh
RUN make ${MAKEOPTS}

# Configure HOME directory
# and persist freech data directory as a volume
ENV HOME /root
VOLUME /root/.freech

# Run freechd by default
ENTRYPOINT ["/freech-core/freechd", "-rpcuser=user", "-rpcpassword=pwd", "-rpcallowip=127.0.0.1", "-printtoconsole"]
CMD ["-port=4033"]