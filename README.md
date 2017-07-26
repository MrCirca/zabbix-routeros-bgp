# Monitoring Mikrotik BGP peer state and uptime on Zabbix
![Logo of ZABBIX](http://www.zabbix.com/img/logo/zabbix_logo_150x39.png) ![Logo of Mikrotik](https://www.mikrotik.com/logo/files/logo_spacing.jpg)<br>
Using external script method on Zabbix, i made two scripts, getting values through [Mikrotik API](https://wiki.mikrotik.com/wiki/Manual:API_Python3).<br>
[Mikrotik API(Python 3)](https://wiki.mikrotik.com/wiki/Manual:API_Python3)  is interactive. So I modified it to print the values I demand and then it disconnects automatically.

Files you need to copy to externalscripts path of zabbix server:

1) bgp_peer_field.sh Calls the API and prints state or uptime of peer name.
2) bgp_peer_names.sh Calls the API and prints peer names. 
3) apriros.py Is the Mikrotik API that is not interactive and can get the output you want.

*Make sure that the files above are executable by zabbix user.*

You should also import **zbx_routeros_bgp.xml** zabbix template on zabbix server.


**Simple script test**:

```shell
 bgp_peer_filed.sh "**RouterOS_USERNAME**" "**RouterOS_PASSWORD**" "**bgp_peer_name**" "**state/uptime**"
```

**Zabbix Discovery Key**:


bgp_peer_names.sh["{HOST.CONN}","{$ROUTEROS_USERNAME}","{$ROUTEROS_PASSWORD}"]

*You should define these macros:  "{$ROUTEROS_USERNAME}" and "{$ROUTEROS_PASSWORD}"


*The reason I created the bgp_peer_names.sh is so that zabbix can discover the peer names and create items for each peer name.*
![Zabbix BGP Monitoring on Mikrotik](https://i.imgur.com/5I8vzrm.png)



