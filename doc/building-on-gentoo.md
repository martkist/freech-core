# Gentoo building instructions

## Install

1. sudo layman -o https://raw.github.com/ddorian1/gentoo-freech-overlay/master/gentoo-freech-overlay.xml -a freech
1. sudo emerge -av freech

## Configuration & web gui

1. mkdir ~/.freech
1. echo -e "rpcuser=user\nrpcpassword=pwd" > ~/.freech/freech.conf
1. chmod 600 ~/.freech/freech.conf
1. git clone https://github.com/martkist/freech-html.git ~/.freech/html

## Start

1. freechd -rpcuser=user -rpcpassword=pwd
1. Open http://127.0.0.1:4032/index.html and use the user/pwd credentials
1. Create your account !
