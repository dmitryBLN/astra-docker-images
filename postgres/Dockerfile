ARG ASTRA_REGISTRY=registry.astralinux.ru
ARG ASTRA_IMAGE=library/alse:1.7.5uu1-mg12.5.0
FROM ${ASTRA_REGISTRY}/${ASTRA_IMAGE}

RUN apt-get update && \
    apt-get install -y postgresql-11 && \
    apt-get install -y --no-install-recommends libnss-wrapper xz-utils zstd locales && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir /docker-entrypoint-initdb.d/ && \
    localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

ENV PATH="/usr/lib/postgresql/11/bin:$PATH" \
    PGDATA="/var/lib/postgresql/data" \
    LANG=en_US.utf8 \
    PG_MAJOR=11

COPY --chmod=0555 scripts/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

EXPOSE 5432

ENTRYPOINT [ "/usr/local/bin/docker-entrypoint.sh" ]
CMD ["postgres"]