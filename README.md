# Filebeat Bash Script
This will help to setup and start filebeat in a automated fashion while going through a interactive questions.

### You should having root privileges
```
# sudo su -
```

### Download the Script and set enough permision on it
```
# cd /root && wget https://raw.githubusercontent.com/keshara/openvpn-for-ubuntu-1804/master/openvpn_install.sh
# chmod 777 filebeat_install.sh
```

### Installation
Execute the downloaded script with "ROOT" privileges...
```
# ./filebeat_install.sh
```

#### Interative questions that will ask;
```
01 - Filebeat version that you need to instal
```
```
02 - Which local file that need to be read out for shipping logs to
```
```
03 - You will have to provide a STRING which could be any name and that will take as a TAG to refer the logs before they are sent out
```
```
04 - Where should the output logs should be reach to(Destination) - two options: logstash or redis
```
```
05 - IP addresses and a TCP port for the above slected destination.
```
