ARG ASTRA_REGISTRY=registry.astralinux.ru
ARG ASTRA_IMAGE=library/alse:1.7.5uu1-mg12.5.0

FROM ${ASTRA_REGISTRY}/${ASTRA_IMAGE}

RUN apt-get update && \
    apt-get install -y -o Dpkg::Options::="--force-confnew" zabbix-frontend-php

RUN apt-get install -yqq curl nginx-unit libnginx-unit-mod-php7.3 locales  postgresql-client-11 iputils-ping && \
    apt-get remove -yqq apache2-utils apache2 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN localedef -i ru_RU -c -f UTF-8 -A /usr/share/locale/locale.alias ru_RU.UTF-8 && \
    localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

RUN useradd -u 1001 -r -g 0 -d /usr/share/zabbix -s /sbin/nologin \
      -c "Default Zabbix User" zabbix && \
      mkdir -p /var/lib/unit /etc/unit /var/run/nginx-unit && \
      chown -R 1001:0 -R /etc/zabbix /usr/share/zabbix /var/lib/unit /var/run/nginx-unit /etc/unit

COPY --chmod=0444 --chown=1001:0 conf/unit.json /etc/unit/unit.json
COPY --chmod=0444 --chown=1001:0 conf/zabbix/* /etc/zabbix/
COPY --chmod=0555 scripts/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

USER 1001
EXPOSE 8080
WORKDIR /usr/share/zabbix

# Поддержка postgresql ниже 13
ENV ZBX_ALLOWUNSUPPORTEDDBVERSIONS=1

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]