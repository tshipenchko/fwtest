#!/bin/bash
# root?
if [[ $EUID -ne 0 ]]; then
	echo -e "MUST RUN AS ROOT USER! use sudo"
	exit 1
fi
# install
apt install -y shadowsocks-libev simple-obfs jq curl psmisc
# exit 1

mkdir -p ./log # create logs folder in workdir
tmp=`mktemp` # temporary files

file=$1
obfs=$2
IFS=' ' read -r -a array <<< `cat $file`
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
	killall -SIGINT ss-local obfs-local && killall -SIGINT ss-local obfs-local
	cp $obfs .tempobfs
	a="obfs=http;obfs-host=$i;fast-open"
	jq --arg a "$a" '.plugin_opts = $a' .tempobfs > "$tmp" && mv "$tmp" .tempobfs
	echo "Checking $i"
	ss-local -c .tempobfs -v & obfspid=$!
	status=`curl -s -o /dev/null -w "%{http_code}" https://www.google.com/`
	kill -SIGINT $obfspid
	case $status in
		200)
			echo "$i is a working host"
			echo "$i is a working host" >> ./log/fwtest.log
			echo "$i is a working host" >> ./log/fwtest.log.s
			;;
		*)
			echo "$i is NOT a working host"
			echo "Error code: $status"
			echo "$i is NOT a working host" >> ./log/fwtest.log
			echo "Error code: $status" >> ./log/fwtest.log
			;;
esac
done
rm .tempobfs
