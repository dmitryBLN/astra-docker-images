ARG ASTRA_REGISTRY=registry.astralinux.ru
ARG ASTRA_IMAGE=library/alse:1.7.5uu1-mg12.5.0


FROM ${ASTRA_REGISTRY}/${ASTRA_IMAGE} as installer

RUN apt-get update && \
    apt-get install -y zabbix-agent


FROM ${ASTRA_REGISTRY}/${ASTRA_IMAGE}

RUN apt-get update && \
    apt-get install -y  libxml2 \
                        unixodbc \
                        libsnmp30 \
                        libopenipmi0 \
                        libevent-2.1-6 \
                        libpcre2-8-0 \
                        libcurl4 \
                        libcurl3-gnutls \
                        libiksemel3 \
                        libodbc1 \
                        libmodbus5 \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN useradd -u 1001 -r -g 0 -d /var/lib/zabbix -s /sbin/nologin \
      -c "Default Zabbix User" zabbix && \
    mkdir -p /etc/zabbix /etc/zabbix/zabbix_agentd.d /var/lib/zabbix /var/log/zabbix && \
    chown 1001:0 -R /etc/zabbix /var/lib/zabbix /var/log/zabbix /etc/zabbix/zabbix_agentd.d

COPY --from=installer --chmod=0555 /usr/bin/zabbix_sender /usr/bin/zabbix_sender
COPY --from=installer --chmod=0555 /usr/sbin/zabbix_agentd /usr/sbin/zabbix_agentd  
COPY --chmod=0555 scripts/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
COPY --chmod=0400 --chown=zabbix:0 conf/zabbix_agentd.conf /etc/zabbix/zabbix_agentd.conf

USER 1001
EXPOSE 10050
WORKDIR /var/lib/zabbix

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["/usr/sbin/zabbix_agentd", "--foreground", "-c", "/etc/zabbix/zabbix_agentd.conf"]