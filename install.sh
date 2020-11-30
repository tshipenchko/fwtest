#!/bin/bash
sudo apt-get update
sudo apt-get install -y git shadowsocks-libev simple-obfs jq curl psmisc; sudo mkdir fwtest
sudo git clone https://github.com/tshipenchko/fwtest tempfwtest; sudo mv -v tempfwtest/* fwtest; sudo rm -rf tempfwtest/
cd fwtest
sudo chmod +x fwtest.sh
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "FireWallTest installed"
echo "How to use: "
echo "./fwtest.sh <hosts> <obfs-server>"
echo "Write hosts separated by a space"
echo "Logs:"
echo "all log ./fwtest/log/fwtest.log"
echo "success log ./fwtest/log/fwtest.log.s"