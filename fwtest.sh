#!/bin/bash
# root?
if [[ $EUID -ne 0 ]]; then
	echo -e "MUST RUN AS ROOT USER! use sudo"
	exit 1
fi
# install
apt install -y shadowsocks-libev simple-obfs jq curl
# exit 1

mkdir -p ./log # создает папку в рабочей директории
tmp=`mktemp` # временные файлы

file=$1
obfs=$2
IFS=' ' read -r -a array <<< `cat $file`
for i in "${array[@]}"
do
	echo $i
done
echo 1

echo "Testing data: `date`" >> ./log/fwtest.log
echo "Testing data: `date`" >> ./log/fwtest.log.s

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
