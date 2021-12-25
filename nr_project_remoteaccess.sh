#!/bin/bash

function inst () {
	sudo apt-get install -y $1
}

function inst2 () {
	git clone https://github.com/htrgouvea/nipe && cd nipe
	sudo cpan install Try::Tiny Config::Simple JSON
	sudo perl nipe.pl install
}

#find apps - "whois" "curl" "ssh" "sshpass" "nmap"

declare -a arr=("whois" "curl" "ssh" "sshpass" "nmap")

for app in "${arr[@]}" 
do 
	if ! command -v $app &> /dev/null
	then
	echo "$app could not be found" 
	inst $app
	fi
done

#find apps - "geoiplookup" 

declare -a arr=("geoiplookup")

for app in "${arr[@]}" 
do 
	if ! command -v $app &> /dev/null
	then
	echo "$app could not be found" 
	inst geoip-bin
	fi
done

#find apps - "nipe.pl" 

declare -a arr=("nipe.pl")

for app in "${arr[@]}" 
do 
	if $(find ./ -name nipe.pl | awk -F/ '{print $NF}') &> /dev/null 
	then
	echo "$app could not be found" 
	inst2 
	fi
done

function anon() {
	cd "nipe"

	sudo perl nipe.pl restart 
	(curl ifconfig.me; echo) | tee >> ip_lst

	for x in $(cat ip_lst | tail -n 1)
	do
		geoiplookup $x | awk '{print $4}' | cut -c 1-2 >> cty
	done

	for x in $(cat cty | tail -n 1)
	do
		if [ $x = SG ]
		then
		echo "Connection from SG, origin country"
		else
		echo "Connection from $x, not origin country"
		fi
	done
}

anon

#To connect to vps

IP=139.59.229.99
PSS='1'

function vps() {

echo “please choose 1 option [nmap / whois]:”
read option

if [ $option == nmap ]
then
	sshpass -p $PSS ssh test@$IP 'mkdir test 2>/dev/null; nmap 8.8.8.8 -p 22 | tee -a test/nmapScan'
fi

if [ $option == whois ]
then
	sshpass -p $PSS ssh test@$IP 'mkdir test 2>/dev/null; whois 8.8.8.8 | tee -a test/whoisScan'
fi
}

vps
