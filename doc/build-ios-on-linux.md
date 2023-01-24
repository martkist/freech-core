IOS (iPhoneOS) Build Instructions and Notes
===========================================
This guide will show you how to build freechd for IOS on a linux machine.

Notes
-----

* Compilation, made on a linux 
* Application, tested on iPhone4 with IOS 7.1.2 (jailbroken)
* All of the commands should be executed in a Terminal application.

Preparation
-----------

You need to install clang and llvm from distribution's repo. Then you need IOS toolchain and SDK.
You can get them from [iOS toolchain based on clang for linux](https://code.google.com/p/ios-toolchain-based-on-clang-for-linux/).

You need to install [openssl](http://cydia.saurik.com/package/openssl/) ([view in cydia...](cydia://package/openssl)) to your
device and copy headers and libraries to your SDK as well.

REQUIRMENTS (leveldb, berkeley db and boost) WILL BE DOWNLOADED AND BUILDED BY `runme-ios-onlinux.sh`
You need also to build [leveldb](http://github.com/google/leveldb), [Berkeley DB](http://download.oracle.com/otn/berkeley-db/db-5.3.28.tar.gz)
for IOS.

And you need the [boost sources](http://www.boost.org/users/download/#live).

Instructions:
-------------

#### Setting required variable

You should check variables set in `runme-ios-onlinux.sh` script.


    export IPHONE_IP=""
    export IOS_SDK=/usr/share/iPhoneOS6.0.sdk
    export ARCH=armv7
    export TARGET=arm-apple-darwin11
    export LINKER_VER=236.3
    export IPHONEOS_DEPLOYMENT_TARGET=6.0
    export TARGET_OS=IOS
    export CC="clang"
    export CXX="clang++"
    export PJC=2
#### Building dependencies and `freechd`

1. Clone the github tree to get the source code and go into the directory.

        git clone https://github.com/martkist/freech-core.git
        cd freech-core/src

2. Building


        ./runme-ios-onlinux.sh

3. If things go south, before trying again, make sure you clean it up:


        make clean

If all went well, you should now have a freechd executable in the freech-core directory.
See the Running instructions below.

Running
-------

If you have been set IPHONE_IP before running script, it's now available at `/usr/bin/freechd` on your device.
We have to first create the RPC configuration file, though.

Run `/usr/bin/freechd` from SSH or on [Mobile Terminal](http://cydia.saurik.com/package/mobileterminal/) to get
the filename where it should be put, or just try these commands:

    mkdir -p "/User/.freech"
    echo -e "rpcuser=user\nrpcpassword=pwd\nrpcallowip=127.0.0.1" > "/User/.freech/freech.conf"
    chmod 600 "/User/.freech/freech.conf"

When next you run it, it will start downloading the blockchain, but it won't
output anything while it's doing this. This process may take several hours. If you see a lonely
`connect: Operation timed out`, don't freak out, it seems to work fine.

Other commands:

    tail -f ~/.freech/debug.log
    ./freechd --help  # for a list of command-line options.
    ./freechd -daemon # to start it as a daemon.
    ./freechd help    # When the daemon is running, to get a list of RPC commands

In order to get the HTML interface, you'll have to download it and link it in .freech:

     git clone https://github.com/martkist/freech-html.git /User/Library/Application\ Support/freech/html

Once you do that, it will be available at http://localhost:4032/home.html

