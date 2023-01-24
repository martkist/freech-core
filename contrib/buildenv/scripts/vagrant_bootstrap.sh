#!/bin/bash

FREECH_CORE_PATH='/home/vagrant/freech-core'
FREECH_HOME='/home/vagrant/.freech'
AS_VAGRANT='sudo -u vagrant'

if [ -n "$1" ]; then
	timezone=$1
else
	timezone="UTC"
fi

bootstrap=$2
compile=$3
run=$4

function failed {
	echo 
	echo 'Something failed !!!!!'
	echo
	exit 1
}
function checkfail {
	if [ ! $? -eq 0 ]; then
		failed
	fi
	sleep 3
}


echo
echo 'Running bootstrap for freech-core'
echo "
bootstrap=$bootstrap
compile=$compile
run=$run
"
echo 
echo ".. setting timezone"
service ntp stop
ntpdate ntp1.sp.se
service ntp start
echo "$timezone" | sudo tee /etc/timezone && dpkg-reconfigure --frontend noninteractive tzdata
#$AS_VAGRANT ln -s /vagrant $FREECH_CORE_PATH


echo '.. fixing permissions'
cd $FREECH_CORE_PATH
find /vagrant/scripts -type d -exec chmod 755 {} \;
find /vagrant/scripts -type f -exec chmod 644 {} \;
chmod 755 /vagrant/scripts/bin/* 

echo '.. checking apt cache'
timestamp_file="$(mktemp)"
touch -d "$(date -R -d '1 day ago')" $timestamp_file
file=/var/cache/apt
if [ $file -ot $timestamp_file ]; then
	apt-get update  
fi


echo '.. configuration & web gui'
if [ ! -d "$FREECH_HOME" ]; then
	$AS_VAGRANT mkdir $FREECH_HOME
	cd $FREECH_HOME
	$AS_VAGRANT touch freech.conf
	echo -e "rpcuser=user\nrpcpassword=pwd\nrpcallowip=*" > freech.conf
	chmod 600 freech.conf
fi

if [ ! -d "$FREECH_HOME/html" ]; then
	cd "$FREECH_HOME"
	git clone https://github.com/martkist/freech-html.git html
	checkfail
fi



if [ $bootstrap -eq 1 ]; then
echo '.. bootstrapping'
	echo '.. installing tools and libraries'
	apt-get install -y git build-essential autoconf libtool libssl-dev libboost-all-dev libdb++-dev libminiupnpc-dev openssl 
	checkfail

	cd $FREECH_CORE_PATH
	$AS_VAGRANT ./bootstrap.sh
	checkfail
fi

if [ $compile -eq 1 ]; then
	echo '.. compiling'
	$AS_VAGRANT make
	checkfail
fi






if [ $run -eq 1 ]; then
	echo '.. launching freechd'
	cd $FREECH_CORE_PATH
	$AS_VAGRANT -H ./freechd -debug -daemon
fi



if [ $? -eq 0 ]; then
  echo
  echo '=================================================================='
  echo "
Done. 
Open http://127.0.0.1:4032/index.html and use the user/pwd credentials
Create your account !
  
If you want to do some development or other stuff then...
 $ vargrant ssh
 $ source freech-core/contrib/buildenv/scripts/activate
 
 This will give you some nice to have commands like
 * freech start|stop   -  to start and stop the server
 * twisted              -  alias to ~/twisted-core/twisted


 Good luck!
 "
else
  failed

fi