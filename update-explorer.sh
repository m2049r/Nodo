#!/bin/bash

#shellcheck source=home/nodo/common.sh
. /home/nodo/common.sh
cd /home/nodo || exit 1

OLD_VERSION_EXP="${1:-$(getvar "versions.exp")}"

RELEASE="$(curl -fs https://raw.githubusercontent.com/MoneroNodo/Nodo/master/release-exp.txt)"
#RELEASE="release-v0.18" # TODO remove when live

if [ -z "$RELEASE" ]; then # Release somehow not set or empty
	showtext "Failed to check for update for Monero Explorer"
	exit 0
fi

if [ "$RELEASE" == "$OLD_VERSION_EXP" ]; then
	showtext "No update for Monero Explorer"
	exit 0
fi

touch "$DEBUG_LOG"

showtext "
####################
Start setup-update-explorer.sh script $(date)
####################
"


#(1) Define variables and updater functions

rm -rf /home/nodo/onion-monero-blockchain-explorer/
showtext "Building Monero Blockchain Explorer..."

{
	git clone -b master https://github.com/moneroexamples/onion-monero-blockchain-explorer.git
	cd onion-monero-blockchain-explorer || exit
	git pull
	mkdir build
	cd build || exit
	cmake ..
	make -j$(nproc --ignore=2) && cp xmrblocks /usr/bin/ && chmod a+x /usr/bin/xmrblocks
} 2>&1 | tee -a "$DEBUG_LOG"

putvar "versions.exp" "$RELEASE"
#
##End debug log
showtext "
####################
End setup-update-explorer.sh script $(date)
####################"
