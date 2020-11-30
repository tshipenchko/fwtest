#!/bin/bash
# root?
if [[ $EUID -ne 0 ]]; then
	echo -e "MUST RUN AS ROOT USER! use sudo"
	exit 1
fi
# install that, if you have errors
# apt install -y shadowsocks-libev simple-obfs jq curl psmisc figlet
# input?
if [ -z "$1" ] || [ -z "$2" ]; then
	echo "Use like that:"
	echo "./fwtest.sh <host-file> <obfs-config>"
	echo "./fwtest.sh ehost obfs.json"
	exit
fi
# banner
cat << "EOF"
 _____ _        __        __    _ _ _____         _   
|  ___(_)_ __ __\ \      / /_ _| | |_   _|__  ___| |_ 
| |_  | | '__/ _ \ \ /\ / / _` | | | | |/ _ \/ __| __|
|  _| | | | |  __/\ V  V / (_| | | | | |  __/\__ \ |_ 
|_|   |_|_|  \___| \_/\_/ \__,_|_|_| |_|\___||___/\__|
                                                      

EOF
echo "by t.me/tshipenchko"
echo "Do you take full responsibility for your actions? (y/n) "
read -r eula
case $eula in
	y | yes | Y | YES)
		echo "starting now"
		;;
	*)
		echo "We cannot continue"
		exit
		;;
esac
mkdir -p ./log # create logs folder in workdir
tmp=`mktemp` # temporary files

file=$1
obfs=$2
IFS=' ' read -r -a array <<< `cat $file`
echo "Hosts:"
for i in "${array[@]}"
do
	echo $i
done

echo "~~~~~~~~~~~~~~~~~~~~~~~" >> ./log/fwtest.log
echo "~~~~~~~~~~~~~~~~~~~~~~~" >> ./log/fwtest.log.s
echo "Testing date: `date`" >> ./log/fwtest.log
echo "Testing date: `date`" >> ./log/fwtest.log.s

#main script

for i in "${array[@]}"
do
	killall -SIGINT ss-local obfs-local
	cp $obfs .tempobfs
	a="obfs=http;obfs-host=$i;fast-open"
	port=`jq '.local_port' .tempobfs`
	jq --arg a "$a" '.plugin_opts = $a' .tempobfs > "$tmp" && mv "$tmp" .tempobfs
	echo "Checking $i"
	ss-local -c .tempobfs -v & obfspid=$!
	sleep 1
	status=`curl --socks5 127.0.0.1:$port -m 3.5 -s -o /dev/null -w "%{http_code}" https://www.google.com/`
	kill -SIGINT $obfspid
	case $status in
		200)
			echo "$i is a working host"
			echo "$i is a working host" >> ./log/fwtest.log
			echo "$i is a working host" >> ./log/fwtest.log.s
			echo "$i" >> ./.temphost
			;;
		*)
			echo "$i is NOT a working host"
			echo "Error code: $status"
			echo "$i is NOT a working host" >> ./log/fwtest.log
			echo "Error code: $status" >> ./log/fwtest.log
			;;
esac
done
killall -SIGINT ss-local obfs-local
rm .tempobfs
echo "~~~~Completed~~~~"
echo "All working hosts:"
echo "All working hosts:" >> ./log/fwtest.log.s
cat .temphost >> ./log/fwtest.log.s
cat .temphost; rm .temphost