#!/bin/bash
echo -e "Starting..\n"
echo -e " "
mkdir -p /opt/filebeat && cd /opt/filebeat

# Download the version
echo -e "Which version of FileBeat that needed to be setup?"
sleep 1
while [[ $fbver != [0-9].[0-9].[0-9] ]] || [[ $fbver == '' ]]
	do
		read -e -p '[E.x. 5.5.0] => ' -i "5.5.0" fbver
	done
echo -e "Downloading..\n"
echo -e " "
wget https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-$fbver-linux-x86_64.tar.gz -q --show-progress
FILENAME=$(ls -tr *.tar.gz 2> /dev/null | head -1)
if [ -z $FILENAME ]; then
	echo "Opps.! looks like the version that you requested is not available."
	exit
fi	
echo -e "Downloading Completed..\n"

# Extract
sleep 1
mkdir -p $fbver
FILENAME=$(ls -tr *.tar.gz | head -1)
tar -xf $FILENAME -C $fbver --strip-components=1
rm -fr $FILENAME
cd $fbver && mkdir config && cd config


# Filebeat Config
cat <<END >filebeat.yaml
filebeat.prospectors:
- input_type: log
  paths:
    - filename.log
  tags: ["testTag"]

output.agent:
  hosts: ["1.1.1.1:3501"]
END


sleep 1
echo -e "Configuring the Agent...?"
sleep 2
read -e -p 'Type for which files that need to be take in. [E.x. /var/log/syslog.log] => ' PATH1
if [[ $PATH1 == *"/"* ]]; then
	PATH1=${PATH1//\//\\\/}
fi
/bin/sed -i s/filename.log/$PATH1/g filebeat.yaml
echo -e " "

sleep 1
read -e -p 'Type the TAGS name that you need to add in for the above mentioned logs. [E.x. testTag] => ' TAG1
/bin/sed -i s/testTAG/$TAG1/g filebeat.yaml
echo -e " "

sleep 1
while [[ "$oagent" != "redis" ]] && [[ "$oagent" != "logstash" ]] || [[ "$oagent" == '' ]]
	do
		read -e -p 'Do you want to ship logs over Redis OR Logstash. [E.x. logstash] => ' oagent
	done
/bin/sed -i s/output.agent/output.$oagent/g filebeat.yaml
echo -e " "

sleep 1
while [[ $IPnPORT == '' ]]
#while [[ IPnPORT != [0-9]*.[0-9]*.[0-9]*.[0-9]*:[0-9]* ]] || [[ $IPnPORT == '' ]]
	do
		read -e -p 'Type the IP address & the TCP Port that that the logs need to be shipped. [E.x. 1.1.1.1:3501] => ' IPnPORT
	done
/bin/sed -i s/1.1.1.1:3501/$IPnPORT/g filebeat.yaml
echo -e " "

# systemD unit file
echo -e "Setting up systemD service files.."
cat <<END >/etc/systemd/system/filebeat.service
[Unit]
Description=Filebeat
After=network.target

[Service]
Type=simple
Restart=always
User=root
Group=root
WorkingDirectory=/opt/filebeat/VERSION
ExecStart=/opt/filebeat/VERSION/filebeat -c /opt/filebeat/VERSION/config/filebeat.yaml

[Install]
WantedBy=multi-user.target
END

# change the systemd file variables
sleep 1
/bin/sed -i s/VERSION/$fbver/g /etc/systemd/system/filebeat.service

echo -e " "
echo "Starting up the filebeat.service"
systemctl daemon-reload
sleep 1
systemctl start filebeat.service
systemctl is-active filebeat.service >/dev/null 2>&1 && echo "Congradulations.. Filebeat is now starting & sending logs" || echo "Something is Wrong.! Check the configuration"
