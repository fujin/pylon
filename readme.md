Pylon
=====
A library designed to allow you to perform simple master election
while knowing little about your peers, for use with Chef.

Requirements
---
* JRuby 1.6 or 1.7, (1.9 mode only)
* ZeroMQ 2.1
* Zookeeper ~3.3.3

Command Line Usage
---
There is a command line 'pylon' script included for starting test
instances of the library.

Give it a shot!
---------------

This will give you two pylon nodes running across eth1, on the tcp ip/port specified, with multicast and multicast loopback enabled. Should see a master election happen! Enjoy.

```
# apt-get isntall libzmq-dev
# apt-get install zookeeperd
$ bundle install
$ bundle exec bin/pylon -l debug --dcell-addr tcp://0.0.0.0:55665 --dcell-id haxstation1
$ bundle exec bin/pylon -l debug --dcell-addr tcp://0.0.0.0:55667 --dcell-id haxstation2
```
