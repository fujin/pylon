Pylon
=====
A library designed to allow you to perform simple master election
while knowing little about your peers, for use with Chef.

Requirements
---
* Ruby 1.9.3
* ZeroMQ 2.1 with OpenPGM support, for encapsulated multicast

Give it a shot!
---------------

This will give you two pylon nodes running across eth1, on the tcp ip/port specified, with multicast and multicast loopback enabled. Should see a master election happen! Enjoy.

```
(sudo) apt-get isntall libzmq-dev
bundle install
bundle exec bin/pylon --minimum-master-nodes 2 --multicast --multicast-interface eth1 --tcp-address 192.168.1.3 --tcp-port 13335 -l debug
bundle exec bin/pylon --minimum-master-nodes 2 --multicast --multicast-interface eth1 --tcp-address 192.168.1.3 --tcp-port 13336 -l debug
```
