#! /bin/bash

which fping > /dev/null 2>&1 
if [ $? -ne 0 ]; then
	echo "can't find fping in path."
	exit 1
fi



source cfg.sh

if [ 1 == 1 ]; then
	ips=$(cat cfgs/{de,at,ch,se,es,no,lu}* | grep Endpoint | cut -d" " -f 3 | cut -d: -f 1)

	for i in $ips; do
	  sudo ip r add $i via $GW
	  sudo iptables -I OUTPUT -p icmp -d "$i" -j ACCEPT
	  sudo iptables -I INPUT -p icmp -s "$i" -j ACCEPT
	done


	echo $ips | xargs fping -c 10 -e 2>&1 | grep -A 9999 xmt/rcv | sort -n -t/ -k 8,8 | tee fping-res.txt

	for i in $ips; do
	  sudo ip r del $i via $GW
	  sudo iptables -D OUTPUT -p icmp -d "$i" -j ACCEPT
	  sudo iptables -D INPUT -p icmp -s "$i" -j ACCEPT
	done

fi



co=0
cat fping-res.txt | head -n 5 | cut -d: -f 1 | while read a; do
  (
    file=$(realpath $(grep -rl "$a:" cfgs/))
    ip=$a
    echo "ip r del 0.0.0.0/1"
    echo "ip r del 128.0.0.0/1"
    echo "ip link del dev $WGI"
    echo "ip link add dev $WGI type wireguard"
    echo "ip r add $a via $GW"
    ADDR=$(cat $file | grep ^Address | cut -d= -f 2 | cut -d"," -f 1)
    DNS=$(cat $file | grep ^DNS | cut -d= -f 2 | cut -d"," -f 1)
    echo "ip a add $ADDR dev $WGI"
    echo "cat $file | grep -v -e ^Address -e ^DNS | wg setconf $WGI /dev/stdin"
    echo "ip link set up dev $WGI"
    echo "ip r add 0.0.0.0/1 dev $WGI"
    echo "ip r add 128.0.0.0/1 dev $WGI"
    echo "echo 'nameserver $DNS' > /etc/resolv.conf"
  ) > con-best-$co.sh
  co=$(( $co + 1 ))
done
