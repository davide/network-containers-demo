FROM node

RUN git clone --single-branch --branch master --depth 1 https://github.com/zerotier/ZeroTierOne.git /source && \
    cd /source && make netcon && \
    mkdir /var/lib/zerotier-one && \
    cp /source/libzerotierintercept.so /var/lib/zerotier-one/ && \
    cp /source/netcon/liblwip.so /var/lib/zerotier-one/ && \
    cp /source/zerotier-netcon-service /var/lib/zerotier-one/ && \
    ln -s /var/lib/zerotier-one/zerotier-netcon-service /var/lib/zerotier-one/zerotier-cli && \
    rm -rf /source

ENV PATH /var/lib/zerotier-one:$PATH

ADD ztnc-docker-entry.sh /var/lib/zerotier-one/ztnc-docker-entry.sh

VOLUME /app

CMD /var/lib/zerotier-one/ztnc-docker-entry.sh && \
    LD_PRELOAD=/var/lib/zerotier-one/libzerotierintercept.so \
    ZT_NC_NETWORK=/var/lib/zerotier-one/nc_${ZT_NETWORK} \
    node /app/index.js
