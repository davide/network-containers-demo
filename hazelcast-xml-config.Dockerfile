FROM hazelcast/hazelcast:latest

RUN apt-get update

RUN git clone --single-branch --branch master --depth 1 https://github.com/zerotier/ZeroTierOne.git /source
RUN apt-get -y install make gcc g++
RUN cd /source && make netcon && \
    mkdir /var/lib/zerotier-one && \
    cp /source/libzerotierintercept.so /var/lib/zerotier-one/ && \
    cp /source/netcon/liblwip.so /var/lib/zerotier-one/ && \
    cp /source/zerotier-netcon-service /var/lib/zerotier-one/ && \
    ln -s /var/lib/zerotier-one/zerotier-netcon-service /var/lib/zerotier-one/zerotier-cli && \
    rm -rf /source

ENV PATH /var/lib/zerotier-one:$PATH

ADD ztnc-docker-entry.sh /var/lib/zerotier-one/ztnc-docker-entry.sh

ADD hazelcast/hazelcast.xml $HZ_HOME

CMD /var/lib/zerotier-one/ztnc-docker-entry.sh && \
    LD_PRELOAD=/var/lib/zerotier-one/libzerotierintercept.so \
    ZT_NC_NETWORK=/var/lib/zerotier-one/nc_${ZT_NETWORK} \
    $HZ_HOME/server.sh
