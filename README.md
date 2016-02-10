
Docker + ZeroTier Network Containers = even more <3
---------------------------------------------------

This repository is a first step to explore how ZeroTier Network Containers
can be used to power Docker applications which are completely independent from
the underlying host network stack.

This combo can be used to scale app capacity, provide disaster recover
capabilities, simplify data backups, speed up data management tasks, etc.

When we cut off the network dependency from the host your application can have
its components running anywhere (on premises, on cloud X, on your Arduino board,
on your octacore smartphone or any random IoT device) and you can start
re-thinking how those components fit and work together.

Keep an eye on the ZeroTier team (they know their stuff) and in the meanwhile
fork this repository and start playing around with this awesome new tech! :)


Demo1 - NodeJS App
==================

This demo is a re-package of the sample app created by the ZeroTier guys when
they announced Network Containers.

Run with:
```bash
docker build -f nodejs.Dockerfile -t nesrait/zerotier-netcon-nodejs .
docker run -it -v $PWD/nodejs:/app -e "ZT_NETWORK=8056c2e21c000001" nesrait/zerotier-netcon-nodejs
```


Demo2 - Hazelcast cluster
=========================

This demo bundles an Hazelcast node configured for multicast discovery.

Run hazelcast server reading configuration from xml file:
```bash
docker build -f hazelcast-xml-config.Dockerfile -t nesrait/zerotier-netcon-hazelcast-xml-config .
docker run -it -v $PWD/hazelcast/hazelcast.xml:/opt/hazelcast/hazelcast.xml -e "ZT_NETWORK=8056c2e21c000001" nesrait/zerotier-netcon-hazelcast-xml-config
```

Which fails while reading the hazelcast.xml:
```
Process id for hazelcast instance is written to location:  /opt/hazelcast/hazelcast_instance.pid
Feb 09, 2016 9:02:20 PM com.hazelcast.config.XmlConfigLocator
INFO: Loading 'hazelcast.xml' from working directory.
Exception in thread "main" java.lang.ArrayIndexOutOfBoundsException: 1
        at com.hazelcast.config.AbstractXmlConfigHelper.schemaValidation(AbstractXmlConfigHelper.java:154)
```

Run hazelcast server using programmatic configuration (which uses multicast by default):
```bash
docker build -f hazelcast-programmatic-config.Dockerfile -t nesrait/zerotier-netcon-hazelcast-programmatic-config .
docker run -it -e "ZT_NETWORK=8056c2e21c000001" nesrait/zerotier-netcon-hazelcast-programmatic-config
```

Which fails with:
```
SEVERE: [LOCAL] [dev] [3.6] Inappropriate ioctl for device
java.net.SocketException: Inappropriate ioctl for device
        at java.net.NetworkInterface.getAll(Native Method)
        at java.net.NetworkInterface.getNetworkInterfaces(NetworkInterface.java:334)
```

It looks like Java is looking for a regular network interface, but
with Network Containers there isn't one.
(TODO: report this)

When that's working we can test that the Hazelcast cluster is working with:
```bash
docker build -f hazelcast-server-and-client.Dockerfile -t nesrait/zerotier-netcon-hazelcast-server-and-client .
docker kill zthz1 zthz2
docker rm zthz1 zthz2
export ZT_NETWORK=8056c2e21c000001
docker run -it --name zthz1 -e "ZT_NETWORK=${ZT_NETWORK}" nesrait/zerotier-netcon-hazelcast-server-and-client
docker run -it --name zthz2 -e "ZT_NETWORK=${ZT_NETWORK}" nesrait/zerotier-netcon-hazelcast-server-and-client
docker exec -it zthz1 \
       bash -c "LD_PRELOAD=/var/lib/zerotier-one/libzerotierintercept.so ZT_NC_NETWORK=/var/lib/zerotier-one/nc_${ZT_NETWORK} java -cp hazelcast-all-3.6.jar:. Client"
docker exec -it zthz2 \
       bash -c "LD_PRELOAD=/var/lib/zerotier-one/libzerotierintercept.so ZT_NC_NETWORK=/var/lib/zerotier-one/nc_${ZT_NETWORK} java -cp hazelcast-all-3.6.jar:. Client"
```

For now this fails with the same error as above:
```
SEVERE: [LOCAL] [dev] [3.6] Inappropriate ioctl for device
java.net.SocketException: Inappropriate ioctl for device
        at java.net.NetworkInterface.getAll(Native Method)
        at java.net.NetworkInterface.getNetworkInterfaces(NetworkInterface.java:334)
```
