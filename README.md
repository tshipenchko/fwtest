# fwtest
FireWall testing for exploits

## How to install
```
bash <(wget -qO- kyyinc.tk/install.sh)
```
OR
```
bash <(curl -Ls kyyinc.tk/install.sh)
```

## How to use
```
./fwtest.sh <hosts_file> <obfs_server_config>
```
Hosts in file must be written separated by a space
There is my obfs server config in obfs.json file, you could use one for testing
Example: 
```
./fwtest.sh ehosts obfs.json
```

## Logs
Main full log file: ./fwtest/log/fwtest.log
Only working hosts log file: ./fwtest/log/fwtest.log.s
