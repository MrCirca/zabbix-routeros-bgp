# Monitoring Mikrotik BGP peer state and uptime on Zabbix
Using external script method on Zabbix, i made two scripts that get values through [Mikrotik API](https://wiki.mikrotik.com/wiki/Manual:API_Python3).<br>
[Mikrotik API(Python 3)](https://wiki.mikrotik.com/wiki/Manual:API_Python3)  is interactive. So i modified it, get values that we want and disconnect.

Project Files:

1) bgp_peer_field.sh Call the API and print state or uptime of peer name.
2) bgp_peer_names.sh Call the API and print peer names. 
3) apriros.py Is the Mikrotik API that is not interactive and can get the output you want.


*The reason that i made bgp_peer_names.sh , cause zabbix can discovery peer names and make item for each peer name*



