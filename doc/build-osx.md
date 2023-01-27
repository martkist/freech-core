OS X Build Instructions and Notes
====================================
This guide will show you how to build freechd for OS X.

Notes
-----

* Tested on OS X 10.9.1 on Intel processors only. PPC is not
supported because it is big-endian.
* All of the commands should be executed in a Terminal application. The
built-in one is located in `/Applications/Utilities`.

Preparation
-----------

You need to install Xcode with all the options checked so that the compiler
and everything is available in /usr not just /Developer. Xcode should be
available on your OS X installation media, but if not, you can get the
current version from https://developer.apple.com/xcode/. If you install
Xcode 4.3 or later, you'll need to install its command line tools. This can
be done in `Xcode > Preferences > Downloads > Components` and generally must
be re-done or updated every time Xcode is updated. If you don't have that
option, you can also type `xcode-select --install` in the Terminal.

There's an assumption that you already have `git` installed, as well. If not,
it's the path of least resistance to install
[GitHub Desktop](https://desktop.github.com/) or
[Git for OS X](https://code.google.com/p/git-osx-installer/). It is also
available via Homebrew or MacPorts.

You will also need to install [MacPorts](https://www.macports.org/)
or [Homebrew](http://brew.sh/) in order to install library
dependencies. It's largely a religious decision which to choose, but current
release builds are done with MacPorts due to better long-term support for
older libraries.

The installation of the actual dependencies is covered in the Instructions
sections below.

Instructions: MacPorts (recommended)
---------------------------------

### Install dependencies

Installing the dependencies using MacPorts is very straightforward.

```
sudo port install boost171 db48@+no_java openssl11 miniupnpc libtool
```

Once installed dependencies, do:

```
./autotool.sh
./configure --enable-logging --with-openssl=/opt/local/libexec/openssl11 --with-boost=/opt/local/libexec/boost/1.71
make -j4
```
(If you have multi core CPU, use "make -j N" where N = the number of your cores)

If things go south, before trying again, make sure you clean it up:

```
make clean
```

If all went well, you should now have a freechd executable in the freech-core directory.
See the Running instructions below.

Instructions: Homebrew
----------------------

#### Install dependencies using Homebrew

```
brew install boost miniupnpc openssl berkeley-db4 autoconf automake libtool
```

### Building `freechd`

1. Clone the github tree to get the source code and go into the directory.

```
git clone https://github.com/martkist/freech-core.git
cd freech-core
```

2. Build freech using autotool

```
./autotool.sh
./configure --enable-logging --with-openssl=/usr/local/opt/openssl --with-libdb=/usr/local/opt/berkeley-db4
make -j4
```
(If you have multi core CPU, use "make -j N" where N = the number of your cores)

3. If things go south, before trying again, make sure you clean it up:

```
make clean
```

Running
-------

It's now available at `./freechd`, provided that you are still in the `freech-core`
directory. We have to first create the RPC configuration file, though.

Run `./freechd` to get the filename where it should be put, or just try these
commands:

```
mkdir -p "/Users/${USER}/Library/Application\ Support/freech"
echo -e "rpcuser=user\nrpcpassword=pwd\nrpcallowip=127.0.0.1" > "/Users/${USER}/Library/Application\ Support/freech/freech.conf"
chmod 600 "/Users/${USER}/Library/Application\ Support/freech/freech.conf"
```

When next you run it, it will start downloading the blockchain, but it won't
output anything while it's doing this unless you use:

```
./freechd -printtoconsole
```

but note that `debug.log` will not be written if you use this option.

This process may take several hours. If you see a lonely
`connect: Operation timed out`, don't freak out, it seems to work fine.

Other commands:

```
tail -f ~/.freech/debug.log
./freechd --help  # for a list of command-line options.
./freechd -daemon # to start it as a daemon.
./freechd help    # When the daemon is running, to get a list of RPC commands
```

In order to get the HTML interface, you'll have to download it and link it in .freech:

```
git clone https://github.com/martkist/freech-html.git /Users/${USER}/Library/Application\ Support/freech/html
```

Once you do that, it will be available at http://user:pwd@localhost:4032/home.html

Troubleshooting
-------
1) You get "DHT network down" in WEB interface on /network.html page
 - Reboot your Mac

