# Ubuntu / Debian building instructions

Tested on a pristine:
 - Ubuntu 13.10 amd64

## Install

1. sudo apt-get update
1. sudo apt-get install git autoconf libtool build-essential libboost-all-dev libssl-dev libdb++-dev libminiupnpc-dev automake
1. git clone https://github.com/martkist/freech-core.git
1. cd freech-core
1. ./autotool.sh
1. ./configure
1. make

## Configuration & web gui

1. mkdir ~/.freech
1. echo -e "rpcuser=user\nrpcpassword=pwd" > ~/.freech/freech.conf
1. chmod 600 ~/.freech/freech.conf
1. git clone https://github.com/martkist/freech-html.git ~/.freech/html

## Start

1. cd freech-core
1. ./freechd -rpcuser=user -rpcpassword=pwd -rpcallowip=127.0.0.1
1. Open http://127.0.0.1:28332/index.html and use the user/pwd credentials
1. Create your account !
