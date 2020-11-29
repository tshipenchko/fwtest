#!/bin/bash
root?
if [[ $EUID -ne 0 ]]; then
	echo -e "MUST RUN AS ROOT USER! use sudo"
	exit 1
fi
install
sudo apt install -y shadowsocks-libev simple-obfs
# exit 1


mkdir -p ./log # создает папку в рабочей директории

file=`basename $1`
obfs=$2
IFS=' ' read -r -a array <<< `cat $file`
for i in "${array[@]}"
do
	echo $i
done


for i in "${array[@]}"
do
	cp $obfs .tempobfs
	jq '.plugin_opts = "obfs=http;obfs-host=$i;fast-open"' .tempobfs
	echo "Checking $i"
	ss-local -c .tempobfs -v || killall -SIGINT ss-local obfs-local && ss-local -c .tempobfs -v & obfspid=$!
	status=`curl -s -o /dev/null -w "%{http_code}" https://www.google.com/`
	kill -SIGINT $obfspid
	case $status in
		200)
			echo "$i is working host"
			echo "$i is working host" >> ./log/fwtest.log
			echo "$i is working host" >> ./log/fwtest.log.s
			;;
		*)
			echo "$i is NOT working host"
			echo "Error code: $status"
			echo "$i is NOT working host" >> ./log/fwtest.log
			echo "Error code: $status" >> ./log/fwtest.log
			;;
esac
done
rm .tempobfs
