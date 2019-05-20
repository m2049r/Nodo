#!/bin/sh
	#Import RPC username
	. /home/pinodexmr/RPCu.sh
	#Import RPC password
	. /home/pinodexmr/RPCp.sh
#Node Version Print
./monero/monerod --rpc-bind-ip=$(hostname -I) --rpc-login=$RPCu:$RPCp version > /var/www/html/node_version.txt