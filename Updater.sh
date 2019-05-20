#!/bin/bash

#Establish IP
	DEVICE_IP="$(hostname -I)"
	echo "PiNode-XMR on ${DEVICE_IP} Checking for available updates"
	sleep "1"
#Download update file
	sleep "1"
	wget -q https://raw.githubusercontent.com/shermand100/pinode-xmr/master/xmr-new-ver.sh -O xmr-new-ver.sh
	echo "Version Info file recieved:"
#Permission Setting
	chmod 755 /home/pinodexmr/current-ver.sh
	chmod 755 /home/pinodexmr/xmr-new-ver.sh
#Load Variables
. /home/pinodexmr/current-ver.sh
. /home/pinodexmr/xmr-new-ver.sh
echo $NEW_VERSION 'New Version'
echo $CURRENT_VERSION 'Current Version'
sleep "3"
if [ $CURRENT_VERSION -lt $NEW_VERSION ]
then
	echo "New Monero Version available...Updating"
	. /home/pinodexmr/monerod-stop.sh
	echo "Monerod stop command sent, allowing 30 seconds for safe shutdown"
	sleep "30"
	rm -rf ./monero
	echo "Deleting Old Version"
	sleep "2"
	mkdir monero
	wget https://downloads.getmonero.org/cli/linuxarm7
	tar -xvf ./linuxarm7 -C ./monero --strip 2
	echo "Software Update Complete - Resuming Node"
	sleep "2"
	sh /home/pinodexmr/monerod-start.sh
	echo "Monero Node Started in background"
	echo "Tidying up leftover installation packages"
	#Clean-up stage
	#Update system version number
	echo "#!/bin/bash
CURRENT_VERSION=$NEW_VERSION" > current-ver.sh
	#Remove downloaded version check file
	rm /home/pinodexmr/xmr-new-ver.sh
	rm /home/pinodexmr/linuxarm7
else
	echo "Your node is up to date, no further action required, I'll check again next week."
fi
