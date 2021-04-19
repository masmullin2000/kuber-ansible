#!/bin/bash

# matches the 1 to 3 digit ip octet value. $IPRH.$IPRH.$IPRH.$IPRH should find an ipaddress
IPRH="\([[:digit:]]\{1,3\}\)"

LINK=$(ip link | awk '{ print $2; }' | grep ^e | sed 's/://g')
IPADD=$(ip a show $LINK | grep ether | awk '{ print $2 }' | sed 's/^[[:xdigit:]]*:[[:xdigit:]]*://g')
FINALIPDIG=$(printf '%d' '0x'`ip a show $LINK | grep ether | awk '{ print $2 }' | sed 's/^[[:xdigit:]]*:[[:xdigit:]]*\(.*\)[[:xdigit:]]\{1,2\}://g'`)
IPADD=$(printf '%d.%d.%d.%d' `echo $IPADD | sed 's/://g' | sed 's/\(..\)/0x\1 /g'`)
IPADD=$(echo $IPADD | sed "s/$IPRH\.$IPRH\.$IPRH.*/\1.\2.\3/g")'.'
GW=$IPADD'1'
IPADD=$IPADD$(($FINALIPDIG+50))

echo $IPADD
echo $GW

sudo ip link set $LINK up
sudo ip a add $IPADD/24 dev $LINK
sudo ip route add default via $GW

#sudo /bin/bash -c "echo 'nameserver 1.1.1.1' > /etc/resolv.conf"