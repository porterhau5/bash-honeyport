bash-honeyport
==============

Script that uses netcat for setting up a listener on a port and adding hosts that connect to it to an iptables DROP rule

Usage
-----
Navigate to install dir:
<pre>cd /root/hp/</pre>
Specify port for netcat to listen on:
<pre>./hp-redhat &lt;TCP port to listen on&gt;</pre>

Example: <pre>./hp-redhat 4444</pre>

Requirements
------------
netcat should be installed on the system. netcat and iptables should be in your $PATH.

Background
----------
I first came across this notion of a "honeyport" in a presentation I attended by John Strand titled "Offensive Countermeasures". The website for the Offensive Countermeasures movement can be found here: http://www.offensivecountermeasures.com/

The idea behind this tool is to identify and block any hosts that connect to a port on a system that has no legitimate purpose. Hosts that do so are either misconfigured, malicious, or compromised, and should be responded to appropriately. It's ideal to integrate the output log from this tool into a SIM/SIEM.

This tool works by setting up a netcat listener on a specified TCP port. Any host that makes a full connection (completes the TCP 3-Way Handshake) will be added to an iptables DROP rule. All input received from the offending host after the 3-WHS is routed to /dev/null. Once the connection terminates, the iptables DROP rule is added, iptables are saved, some metadata is sent to a log file, and the netcat process is restarted.

This first version only supports the syntax for RedHat/CentOS-flavored machines.

Output log
----------
By default, will write to "list.txt" in the current working directory. Logs in the following format:
sip,datestamp,timestamp,timezone,timezoneoffset,epoch
* sip: IP of the offending host
* datestamp: YYYY-MM-DD
* timestamp: HH:mm:SS
* timezone: e.g., EDT
* timezoneoffset: e.g., -0400
* epoch: Seconds since Jan 1, 1970

I provided a few different date and timestamp formats so users already have a few different options for correlation at their disposal.

TODO
----
* Incorporate something equivalent for ubuntu/debian
* Put some more general checks in (e.g., valid input params)
