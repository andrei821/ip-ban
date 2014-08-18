#!/bin/sh

##Country BAN by IP using ipset & iptables
##Author: Andrei Manea (hello@andreimanea.com)

ALL_COUNTRYS=`curl -s http://www.ipdeny.com/ipblocks/data/countries/ --list-only | sed -n 's%.*href="\([^.]*\.zone\)".*%\n\1%; ta; b; :a; s%.*\n%%; p'`

echo "\n\n*********************\n"
echo "BAN IP BY COUNTRY SCRIPT\nUSE IT WITH CAUTION AND TRY NOT TO BAN YOURSELF\n"
echo "1 - List Active BAN's \n2 - Add BAN \n3 - Remove BAN \n*********************\n"
read -p "Choose your option : " name

case $name in
        1)
         iptables -v --list INPUT|grep match-set|awk '{print $11}'
         ;;
	2)
	 echo "Country List \n\n"
         echo $ALL_COUNTRYS|xargs -n8  printf "%-10s | %-10s| %-10s|%-10s|%-10s | %-10s| %-10s|%-10s|\n"
         read -p "Please select the Country Code that you want to block (Ex: cn.zone): " CODE
	 ipset -N $CODE nethash
         for ip in `wget -O - http://www.ipdeny.com/ipblocks/data/countries/$CODE`; do ipset -A $CODE $ip; done
         ipset save $CODE
         iptables -A INPUT -m set --match-set $CODE src -j DROP
         ;;
        3)
         echo "\n\nActive BAN List \n"
         iptables -v --list INPUT|grep match-set|awk '{print $11}'
         echo "\n\n"
         read -p "Please select the Country Code that you want to REMOVE (Ex: cn.zone): " UNBAN
         iptables -D INPUT -m set --match-set $UNBAN src -j DROP
         ;;
        *)
         echo "\n You have chose a wrong number. Please dial again\n"
esac
