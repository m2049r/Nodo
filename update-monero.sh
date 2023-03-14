#!/bin/bash

. ./common.sh

#Error Log:
touch "$DEBUG_LOG"
echo "
####################
Start setup-update-monero.sh script $(date)
####################
" 2>&1 | tee -a "$DEBUG_LOG"

#Download variable for current monero release version
#FIXME: change url
wget -q https://raw.githubusercontent.com/monero-ecosystem/PiNode-XMR/master/release.sh -O /home/nanode/release.sh
#Permission Setting
chmod 755 /home/nanode/release.sh
#Load boot status - condition the node was last run
#shellcheck source=home/nanode/bootstatus.sh
. /home/nanode/bootstatus.sh
#Load Variables
#shellcheck source=home/nanode/release.sh
. /home/nanode/release.sh

	##Configure temporary Swap file if needed (swap created is not persistant and only for compiling monero. It will unmount on reboot)
if (whiptail --title "Nanode Monero Updater" --yesno "For Monero to compile successfully 2GB of RAM is required.\n\nIf your device does not have 2GB RAM it can be artificially created with a swap file\n\nDo you have 2GB RAM on this device?\n\n* YES\n* NO - I do not have 2GB RAM (create a swap file)" 18 60); then
	showtext "Swap file unchanged"
		else
			{
				sudo fallocate -l 2G /swapfile
				sudo chmod 600 /swapfile
				sudo mkswap /swapfile
				sudo swapon /swapfile
			} 2>&1 | tee -a "$DEBUG_LOG"
			showtext "Swap file of 2GB Configured and enabled"
			free -h
fi


		#ubuntu /dev/null odd requiremnt to set permissions
		sudo chmod 666 /dev/null

		#Stop Node to make system resources available.
		sudo systemctl stop blockExplorer.service \
			moneroPrivate.service \
			moneroTorPrivate.service \
			moneroTorPublic.service \
			moneroPublicFree.service \
			moneroI2PPrivate.service \
			moneroCustomNode.service \
			moneroPublicRPCPay.service
		echo "Monero node stop command sent, allowing 30 seconds for safe shutdown"
		echo "Deleting Old Version"
		rm -rf /home/nanode/monero/

# ********************************************
# ******START OF MONERO SOURCE BULD******
# ********************************************
log "manual build of gtest for --- Monero"
{
sudo apt-get install libgtest-dev -y
cd /usr/src/gtest || exit 1
sudo cmake .
sudo make
sudo mv lib/libg* /usr/lib/
cd || exit 1
log "Check dependencies installed for --- Monero"
sudo apt-get update
sudo apt-get install build-essential cmake pkg-config libssl-dev libzmq3-dev libunbound-dev libsodium-dev libunwind8-dev liblzma-dev libreadline6-dev libldns-dev libexpat1-dev libpgm-dev qttools5-dev-tools libhidapi-dev libusb-1.0-0-dev libprotobuf-dev protobuf-compiler libudev-dev libboost-chrono-dev libboost-date-time-dev libboost-filesystem-dev libboost-locale-dev libboost-program-options-dev libboost-regex-dev libboost-all-dev libboost-serialization-dev libboost-system-dev libboost-thread-dev ccache doxygen graphviz -y
} 2>&1 | tee -a "$DEBUG_LOG"


showtext "Downloading Monero "

git clone --recursive https://github.com/monero-project/monero
showtext "Building Monero
****************************************************
****************************************************
***This will take a while - Hardware Dependent***
****************************************************
****************************************************"
cd monero && git submodule init && git submodule update
git checkout $RELEASE
git submodule sync && git submodule update
USE_SINGLE_BUILDDIR=1 make 2>&1 | tee -a "$DEBUG_LOG"
cd || exit 1

# ********************************************
# ********END OF MONERO SOURCE BUILD **********
# ********************************************

#Make dir .bitmonero to hold lmdb. Needs to be added before drive mounted to give mount point. Waiting for monerod to start fails mount.
mkdir .bitmonero 2>&1 | tee -a "$DEBUG_LOG"
#Clean-up used downloaded files
rm -R ~/temp

		#Update system version number
		echo "#!/bin/bash
		CURRENT_VERSION=$NEW_VERSION" > /home/nanode/current-ver.sh
		#cleanup old version number file
		rm /home/nanode/xmr-new-ver.sh



#Define Restart Monero Node
		# Key - BOOT_STATUS
		# 2 = idle
		# 3 || 5 = private node || mining node
		# 4 = tor
		# 6 = Public RPC pay
		# 7 = Public free
		# 8 = I2P
		# 9 tor public
	if [ $BOOT_STATUS -eq 2 ]
then
		whiptail --title "Monero Update Complete" --msgbox "Update complete, Node ready for start. See web-ui at $(hostname -I) to select mode." 16 60
else
	case $BOOT_STATUS in
		3)
			sudo systemctl start moneroPrivate.service
			;;
		4)
			sudo systemctl start moneroTorPrivate.service
			;;
		# 5) TODO apparently not needed
		# 	sudo systemctl start moneroMiningNode.service
		# 	;;
		6)
			sudo systemctl start moneroPublicRPCPay.service
			;;
		7)
			sudo systemctl start moneroPublicFree.service
			;;
		8)
			sudo systemctl start moneroI2PPrivate.service
			;;
		9)
			sudo systemctl start moneroTorPublic.service
			;;
		*)
			log "Very strange"
			;;
	esac
	whiptail --title "Monero Update Complete" --msgbox "Update complete, Your Monero Node has resumed." 16 60
fi

##End debug log
log "Update Complete
####################
End setup-update-monero.sh script $(date)
####################"

rm ~/release.sh

./setup.sh
