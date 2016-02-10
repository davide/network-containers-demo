#!/bin/bash

# Run zerotier-netcon-service and wait for an identity to be generated
/var/lib/zerotier-one/zerotier-netcon-service -d
while [ ! -f /var/lib/zerotier-one/identity.secret ]; do
  sleep 0.1
done

# Join network
echo "Joining ZeroTier Network ${ZT_NETWORK}"
/var/lib/zerotier-one/zerotier-cli join ${ZT_NETWORK}

# Wait for join to be complete
printf "Waiting for address..."
virtip4=""
while [ ! -s /var/lib/zerotier-one/networks.d/${ZT_NETWORK}.conf ]; do
  sleep 0.2
  printf "."
done
while [ -z "$virtip4" ]; do
  sleep 0.2
  printf "."
  virtip4=`/var/lib/zerotier-one/zerotier-cli listnetworks | grep -F ${ZT_NETWORK} | cut -d ' ' -f 9 | sed 's/,/\n/g' | grep -F '.' | cut -d / -f 1`
done

echo ' ready!'
echo 'ZeroTier address is' $virtip4

# Setup environment variables
# -- commented out since we'll do this before the server start
# export LD_PRELOAD=/var/lib/zerotier-one/libzerotierintercept.so
# export ZT_NC_NETWORK=/var/lib/zerotier-one/nc_${ZT_NETWORK}
