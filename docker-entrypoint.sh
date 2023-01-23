#!/bin/bash
set -e

BRIDGE_IP=$(ip ro get 8.8.8.8 | grep -oP '(?<=via )([\d\.]+)')

exec /freech-core/freechd -rpcuser=user -rpcpassword=pwd -rpcallowip=${BRIDGE_IP} -htmldir=/freech-html -printtoconsole -port=28333 $*
