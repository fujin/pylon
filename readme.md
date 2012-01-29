Pylon
=====
A library designed to allow you to perform simple master election
while knowing little about your peers, for use with Chef.

Requirements
---
* Ruby 1.9.3
* ZeroMQ 2.1 with OpenPGM support, for encapsulated multicast

Command Line Usage
---
There is a command line 'pylon' script included for starting test
instances of the library. Options:

```
$ bin/pylon --help
Usage: bin/pylon (options)
    -c, --config CONFIG              The configuration file to use
    -d, --daemonize                  send pylon to the background
    -g, --group GROUP                Group to set privilege to
    -l, --log_level LEVEL            Set the log level (debug, info, warn, error, fatal) (required)
    -m, --minimum-master-nodes NODES How many nodes to wait for before starting master election
    -M, --multicast                  Enable multicast support via encapuslated pragmatic general multicast
    -a, --multicast-address ADDRESS  Address to use for UDP multicast
    -i INTERFACE,                    Interface to use to send multicast over
        --multicast-interface
    -L, --multicast-loopback         Enable multicast over loopback interfaces
    -p, --multicast-port PORT        Port to use for UDP multicast
    -t, --tcp-address TCPADDRESS     Interface to use to bind request socket to
    -P, --tcp-port TCPPORT           Port to bind request socket to
    -u, --user USER                  User to set privilege to
    -h, --help                       Show this message
```

Give it a shot!
---------------

This will give you two pylon nodes running across eth1, on the tcp ip/port specified, with multicast and multicast loopback enabled. Should see a master election happen! Enjoy.

```
# apt-get isntall libzmq-dev
$ bundle install
$ bundle exec bin/pylon --minimum-master-nodes 2 --multicast --multicast-interface eth1 --tcp-address 192.168.1.3 --tcp-port 13335 -l debug
$ bundle exec bin/pylon --minimum-master-nodes 2 --multicast --multicast-interface eth1 --tcp-address 192.168.1.3 --tcp-port 13336 -l debug
```
