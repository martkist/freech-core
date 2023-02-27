# Freech - p2p freedom of speech

Bitcoin Copyright (c) 2009 - 2013 Bitcoin Core developers  
libtorrent Copyright (c) 2003 - 2007, Arvid Norberg  
twister Copyright (c) 2013 - 2018 Miguel Freitas  
Freech Copyright (c) 2023 Martkist Core developers  

## What is Freech?

Freech is an experimental peer-to-peer microblogging software forked from 
[twister-core](https://github.com/miguelfreitas/twister-core) by Miguel Freitas.

User registration and authentication is provided by a bitcoin-like network, so
it is completely decentralized (does not depend on any central authority).

Post distribution uses kademlia DHT network and bittorrent-like swarms, both
are provided by libtorrent.

Both Bitcoin and libtorrent versions included here are highly patched and do
not interoperate with existing networks (on purpose).

## Compiling

Build instructions are in flux as we improve the state of the forked freech-core, which had incomplete build instructions. See `docs/build-XXX.md`.

You can also make reference to the Dockerfiles in `docker` and `releases` to guide you. Note the `releases` are cross compiled with dependencies built from source, and the compiliation steps on the native OS would be considerbly simpler when using precompiled packages.

Alternatively, you can run Freech on an isolated Linux container, using [Docker](https://www.docker.com/). First, [install Docker on your system](https://docs.docker.com/installation/#installation). Then run:

    # Leave out the "sudo -E" if you added yourself to the "docker" group
    sudo -E ./freech-on-docker run --remote

The above command downloads and runs a [pre-built image](https://registry.hub.docker.com/u/martkist/freech) from the Docker index. You can also build and run your own container:

    sudo -E ./freech-on-docker build
    sudo -E ./freech-on-docker run

## Release Builds

Run `FREECH_TAG=v0.9.35 ./build.sh` in `releases` to produce macOS, Unix and Windows release builds. This replaces the legacy `gitian` build process until we can migrate to `Guix`. Release builds use the Bitcoin `depends` infrastructure to build dependencies, and can be updated with the Bitcoin equivalents as needed.

## Freech Server

1. [Install Docker](https://docs.docker.com/engine/install/)

2. Prepare a `freech.conf` in e.g. `/home/<yourusername>/freech`:
```
gen=1
addnode=91.197.0.248:4033
addnode=195.135.252.162:4033
```

This command tells Freech to contribute to the network by mining, and allows you to specify nodes for faster startup.

3. Start your container and publish the default Freech ports (4033) and various DHT ports:
```
docker run -d --cpus=0.10 --restart always --publish 4033:4033 --publish 4433:4433 --publish 5033:5033 --publish 5033:5033/udp --mount type=bind,source=/home/user/freech,target=/root/.freech -it martkist/freechd:v0.9.35
```

This command limits your CPU miner to 10% usage, and ensures that your container will restart on failure/server restart.

## License

Bitcoin is released under the terms of the MIT license. See `COPYING` for more
information or see https://opensource.org/licenses/MIT.

libtorrent is released under the BSD-license.

freech specific code is released under the MIT license or BSD, you choose.
(it shouldn't matter anyway, except for the "non-endorsement clause").

## Development process

There is no development process defined yet.

Developers of either bitcoin or libtorrent are welcomed and will be granted
immediate write-access to the repository (a small retribution for
bastardizing their codebases).

## Testing

Some security checks are disabled (temporarily) allowing multiple clients per IP.
Therefore it is possible to run multiple freechd instances at the same machine:

    $ freechd -datadir=/tmp/freech1 -port=30001 -daemon -rpcuser=user -rpcpassword=pwd -rpcallowip=127.0.0.1 -rpcport=40001
    $ freechd -datadir=/tmp/freech2 -port=30002 -daemon -rpcuser=user -rpcpassword=pwd -rpcallowip=127.0.0.1 -rpcport=40002
    $ freechd -rpcuser=user -rpcpassword=pwd -rpcallowip=127.0.0.1 -rpcport=40001 addnode <external-ip>:30002 onetry

Note: some features (like block generation and dht put/get) do now work unless
the network has at least two nodes, like these two instances in the example above.

## Wire protocol

Bitcoin and libtorrent protocol signatures have been changed on purpose to
make freech network incompatible. This avoids the so called
["merge bug"](http://blog.notdot.net/2008/6/Nearly-all-DHT-implementations-vulnerable-to-merge-bug).

- Bitcoin signature changed from "f9 be b4 d9" to "f0 da bb d2".
- Bitcoin port changed from 8333 to 4033.
- Torrent signature changed from "BitTorrent protocol" to "freech protocollll".
- Torrent/DHT query changed from "y" to "z"
- Torrent/DHT answer changed from "a" to "x"

## Quick JSON command examples

In order to use JSON-RPC you must set user/password/port by either command
line or configuration file. This is the same as in [bitcoin](https://en.bitcoin.it/wiki/Running_Bitcoin)
except that freech config file is `/home/user/.freech/freech.conf`

To create a new (local) user key:

    ./freechd createwalletuser myname

This command returns the secret which can be used to recreate the key in a
different computer (in order to access the account). The user should be
encouraged to make a copy of this information, either by printing, snapshoting
or even writing it down to a piece of paper.

The newly created user only exists in the local database (wallet), so
before the user is able to fully use the system (post messages), his public
key must be propagated to the network:

    ./freechd sendnewusertransaction myname

The above command may take a few seconds to run, depending on your CPU. This
is normal.

To create the first (1) public post:

    ./freechd newpostmsg myname 1 "hello world"

To add some users to the following list:

    ./freechd follow myname '["myname","myfriend"]'

To get the last 5 posts from the users we follow:

    ./freechd getposts 5 '[{"username":"myname"},{"username":"myfriend"}]'

To send a new (private) direct message:

    ./freechd newdirectmsg myname 2 myfriend "secret message"

Notes for `newdirectmsg`:

- The post number (2) follows the same numbering as `newpostmsg`, make
sure they don't clash.

- The recipient must be your follower.

To get the last 10 direct messages to/from remote user:

    ./freechd getdirectmsgs myname 10 '[{"username":"myfriend"}]'

Notes for `getdirectmsgs`:

- These direct message IDs (max_id, since_id etc) are not related to post
numbers. The numbering is local and specific to this thread.

- This function will return messages which have been successfully decrypted
upon receiving or that have been sent by this same computer. A different
computer, sharing the same account, will see the same received, but not the
same sent messages.

To setup your profile:

    ./freechd dhtput myname profile s '{"fullname":"My Name","bio":"just another user","location":"nowhere","url":"freech.net.co"}' myname 1

Note: increase the revision number (the last parameter) whenever you want to
update something using dhtput.

To obtain the profile of another user:

    ./freechd dhtget myfriend profile s

To obtain the full list of commands

    ./freechd help


## Running the web interface

First you'll need to grab the latest version of the web UI code and put it
in your freech data dir:

    cd ~/.freech/
    git clone https://github.com/martkist/freech-html.git ./html

In OS X

    cd ~/Library/Application\ Support/freech
    git clone https://github.com/martkist/freech-html.git ./html

Next, run the freech daemon. The RPC username and password are currently
hard coded as "user" and "pwd" in the web client so you'll need to specify
them:

    ./freechd -rpcuser=user -rpcpassword=pwd -rpcallowip=127.0.0.1

Visit [http://user:pwd@localhost:4032](http://user:pwd@localhost:4032)
in your web browser and you should see a page asking you to choose between the
Desktop and Mobile interfaces.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md)

## License

See [COPYING](COPYING)

