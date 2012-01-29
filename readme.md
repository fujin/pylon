Pylon
=====
A library designed to allow you to perform simple master election
while knowing little about your peers, for use with Chef.


Give it a shot!
---------------

This will give you two pylon nodes running across eth1, on the tcp ip/port specified, with multicast and multicast loopback enabled. Should see a master election happen! Enjoy.

```
(sudo) apt-get isntall libzmq-dev
bundle install
bundle exec bin/pylon -M -m 2 -i eth1 -t 192.168.1.3 -l debug -P 13335 -L
bundle exec bin/pylon -M -m 2 -i eth1 -t 192.168.1.3 -l debug -P 13336 -L
```
