ARG ASTRA_REGISTRY=registry.astralinux.ru
ARG ASTRA_IMAGE=library/alse:1.7.5uu1-mg12.5.0


FROM ${ASTRA_REGISTRY}/${ASTRA_IMAGE} as installer

RUN apt-get update && \
    apt-get install -y zabbix-server-pgsql


FROM ${ASTRA_REGISTRY}/${ASTRA_IMAGE}

RUN apt-get update && \
    apt-get install -y postgresql-client-11 \
                        libxml2 \
                        unixodbc \
                        libsnmp30 \
                        libopenipmi0 \
                        libevent-2.1-6 \
                        libpcre2-8-0 \
                        libcurl4 \
                        libcurl3-gnutls \
                        libiksemel3 \
                        libodbc1 \
                        libldap-2.4-2 \
                        libpq5 \
                        libmodbus5 \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN useradd -u 1001 -r -g 0 -d /var/lib/zabbix -s /sbin/nologin \
      -c "Default Zabbix User" zabbix && \
    mkdir -p /var/lib/zabbix /var/log/zabbix /usr/share/doc/zabbix-server-postgresql && \
    chown 1001:0 -R /var/lib/zabbix /var/log/zabbix /usr/share/doc/zabbix-server-postgresql

COPY --from=installer --chmod=0555 /usr/bin/zabbix_get /usr/bin/zabbix_get
COPY --from=installer --chmod=0555 /usr/bin/zabbix_js /usr/bin/zabbix_js
COPY --from=installer --chmod=0555 /usr/sbin/zabbix_server /usr/sbin/zabbix_server
  
COPY --chmod=0555 scripts/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
COPY --chmod=0400 --chown=zabbix:0 conf/zabbix_server.conf /etc/zabbix/zabbix_server.conf
COPY --chown=1001:0 contrib/* /usr/share/doc/zabbix-server-postgresql/

USER 1001
EXPOSE 10051
WORKDIR /var/lib/zabbix

# Поддержка postgresql ниже 13
ENV ZBX_ALLOWUNSUPPORTEDDBVERSIONS=1

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["/usr/sbin/zabbix_server", "--foreground", "-c", "/etc/zabbix/zabbix_server.conf"]