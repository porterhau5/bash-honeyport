#!/bin/bash

# +---------------------------------------------------------------+
# | Name: hp-redhat.sh                                            |
# |                                                               |
# | Purpose: Honeyport for redhat systems                         |
# |                                                               |
# | Date: 2012/10/26                                              |
# |                                                               |
# | Usage: ./hp-redhat.sh <port>                                  |
# |                                                               |
# | Description: Uses netcat to set up a listener on a specified  |
# |     port. If a host makes a full TCP connection (3-WHS) on    |
# |     this port, then add an iptables rule to block all traffic |
# |     from that host. The idea is to blacklist hosts that are   |
# |     connecting to ports that they have no legitimate reason to|
# |     connect to.                                               |
# |                                                               |
# |     Some metadata is logged to list.txt                       |
# +---------------------------------------------------------------+

# Check for input param
if [[ -z $1 ]]; then
    echo "Usage: $0 <port to listen on>"
    echo "Exiting"
    exit
else
    echo "Starting honeyport on $1/tcp"
    # By default, when a session ends with a netcat listener, the netcat
    # process will die. This while loop will kick up a new nc process
    # after each session.
    while :; 
    do 
        # The next line does the following:
        #    sets up netcat listener on $1
        #    sends all received input to /dev/null
        #    grep and cut commands extract source IP, saves it to $IP
        IP=`nc -v -l $1 2>&1 1> /dev/null | grep from | cut -d\  -f 3`
        # iptables rule to drop source IP
        iptables -I INPUT -p tcp -s ${IP} -j DROP
        # Save iptables with new rule
        /etc/init.d/iptables save 1> /dev/null
        # Send some metadata information to a log file
        echo "${IP},`date +"%Y-%m-%d,%T,%Z,%z,%s"`" >> list.txt
        # Send some metadata information to the console
	echo "Caught: ${IP} on `date +"%Y-%m-%d at %T, now restarting..."`"
    done
fi
