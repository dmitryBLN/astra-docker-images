#!/bin/bash

set -o pipefail

set -e

# Script trace mode
if [ "${DEBUG_MODE,,}" == "true" ]; then
    set -o xtrace
fi

# Default Zabbix installation name
# Used only by Zabbix web-interface
: ${ZBX_SERVER_NAME:="Zabbix docker"}
# Default Zabbix server port number
: ${ZBX_SERVER_PORT:="10051"}

# Default timezone for web interface
: ${PHP_TZ:="Europe/Moscow"}

# Default directories
# Configuration files directory
ZABBIX_ETC_DIR="/etc/zabbix"
# Web interface www-root directory
ZABBIX_WWW_ROOT="/usr/share/zabbix"
# Nginx Unit conf path
UNIT_CONF_PATH="/etc/unit/unit.json"
# Nginx Unit web-socket path
UNIT_UNIXSOCKET_PATH="/var/run/nginx-unit/control-unit.sock"
# Nginx Unit web-socket path
UNIT_PID_PATH="/var/run/nginx-unit/unit.pid"
# Nginx Unit data path
UNIT_DATA_PATH="/var/lib/unit"

# usage: file_env VAR [DEFAULT]
# as example: file_env 'MYSQL_PASSWORD' 'zabbix'
#    (will allow for "$MYSQL_PASSWORD_FILE" to fill in the value of "$MYSQL_PASSWORD" from a file)
# unsets the VAR_FILE afterwards and just leaving VAR
file_env() {
    local var="$1"
    local fileVar="${var}_FILE"
    local defaultValue="${2:-}"

    if [ "${!var:-}" ] && [ "${!fileVar:-}" ]; then
        echo "**** Both variables $var and $fileVar are set (but are exclusive)"
        exit 1
    fi

    local val="$defaultValue"

    if [ "${!var:-}" ]; then
        val="${!var}"
        echo "** Using ${var} variable from ENV"
    elif [ "${!fileVar:-}" ]; then
        if [ ! -f "${!fileVar}" ]; then
            echo "**** Secret file \"${!fileVar}\" is not found"
            exit 1
        fi
        val="$(< "${!fileVar}")"
        echo "** Using ${var} variable from secret file"
    fi
    export "$var"="$val"
    unset "$fileVar"
}

# Check prerequisites for PostgreSQL database
check_variables() {
    file_env POSTGRES_USER
    file_env POSTGRES_PASSWORD

    : ${DB_SERVER_HOST:="postgres-server"}
    : ${DB_SERVER_PORT:="5432"}

    DB_SERVER_ZBX_USER=${POSTGRES_USER:-"zabbix"}
    DB_SERVER_ZBX_PASS=${POSTGRES_PASSWORD:-"zabbix"}

    : ${DB_SERVER_SCHEMA:="public"}

    DB_SERVER_DBNAME=${POSTGRES_DB:-"zabbix"}

    : ${POSTGRES_USE_IMPLICIT_SEARCH_PATH:="false"}
}

check_db_connect() {
    echo "********************"
    echo "* DB_SERVER_HOST: ${DB_SERVER_HOST}"
    echo "* DB_SERVER_PORT: ${DB_SERVER_PORT}"
    echo "* DB_SERVER_DBNAME: ${DB_SERVER_DBNAME}"
    echo "* DB_SERVER_SCHEMA: ${DB_SERVER_SCHEMA}"
    if [ "${DEBUG_MODE,,}" == "true" ]; then
        echo "* DB_SERVER_ZBX_USER: ${DB_SERVER_ZBX_USER}"
        echo "* DB_SERVER_ZBX_PASS: ${DB_SERVER_ZBX_PASS}"
    fi
    echo "********************"

    if [ -n "${DB_SERVER_ZBX_PASS}" ]; then
        export PGPASSWORD="${DB_SERVER_ZBX_PASS}"
    fi

    WAIT_TIMEOUT=5

    if [ "${POSTGRES_USE_IMPLICIT_SEARCH_PATH,,}" == "false" ] && [ -n "${DB_SERVER_SCHEMA}" ]; then
        PGOPTIONS="--search_path=${DB_SERVER_SCHEMA}"
        export PGOPTIONS
    fi

    if [ -n "${ZBX_DBTLSCONNECT}" ]; then
        PGSSLMODE=${ZBX_DBTLSCONNECT//_/-}
        export PGSSLMODE=${PGSSLMODE//required/require}
        export PGSSLROOTCERT=${ZBX_DBTLSCAFILE}
        export PGSSLCERT=${ZBX_DBTLSCERTFILE}
        export PGSSLKEY=${ZBX_DBTLSKEYFILE}
    fi

    while [ ! "$(psql --host ${DB_SERVER_HOST} --port ${DB_SERVER_PORT} --username ${DB_SERVER_ZBX_USER} --dbname ${DB_SERVER_DBNAME} --list --quiet 2>/dev/null)" ]; do
        echo "**** PostgreSQL server is not available. Waiting $WAIT_TIMEOUT seconds..."
        sleep $WAIT_TIMEOUT
    done

    unset PGPASSWORD
    unset PGOPTIONS
    unset PGSSLMODE
    unset PGSSLROOTCERT
    unset PGSSLCERT
    unset PGSSLKEY
}

prepare_web_server() {
    WAITLOOPS=5
    SLEEPSEC=1

    echo "Starting Unit daemon for initial configuration..."
    unitd --control unix:$UNIT_UNIXSOCKET_PATH \
            --pid  $UNIT_PID_PATH \
            --user 1001 \
            --group 1001 \
            --log /dev/stdout
    for i in $(/usr/bin/seq $WAITLOOPS); do
        if [ ! -S $UNIT_UNIXSOCKET_PATH ]; then
            echo "Waiting for control socket to be created..."
            /bin/sleep $SLEEPSEC
        else
            break
        fi
    done

    echo "
    Configuring Unit: "
    curl -sS -X PUT --data-binary @$UNIT_CONF_PATH --unix-socket $UNIT_UNIXSOCKET_PATH http://localhost/config/

    echo "Stopping Unit daemon after initial configuration..."
    kill -TERM $(/bin/cat $UNIT_PID_PATH)
    for i in $(/usr/bin/seq $WAITLOOPS); do
        if [ -S $UNIT_UNIXSOCKET_PATH ]; then
            echo "$0: Waiting for control socket to be removed..."
            /bin/sleep $SLEEPSEC
        else
            break
        fi
    done
    if [ -S $UNIT_UNIXSOCKET_PATH ]; then
        kill -KILL $(/bin/cat $UNIT_PID_PATH)
        rm -f $UNIT_UNIXSOCKET_PATH
    fi
}

prepare_zbx_web_config() {
    echo "** Preparing Zabbix frontend configuration file"

    : ${ZBX_DENY_GUI_ACCESS:="false"}
    export ZBX_DENY_GUI_ACCESS=${ZBX_DENY_GUI_ACCESS,,}
    export ZBX_GUI_ACCESS_IP_RANGE=${ZBX_GUI_ACCESS_IP_RANGE:-"['127.0.0.1']"}
    export ZBX_GUI_WARNING_MSG=${ZBX_GUI_WARNING_MSG:-"Zabbix is under maintenance."}

    export ZBX_MAXEXECUTIONTIME=${ZBX_MAXEXECUTIONTIME:-"600"}
    export ZBX_MEMORYLIMIT=${ZBX_MEMORYLIMIT:-"128M"}
    export ZBX_POSTMAXSIZE=${ZBX_POSTMAXSIZE:-"16M"}
    export ZBX_UPLOADMAXFILESIZE=${ZBX_UPLOADMAXFILESIZE:-"2M"}
    export ZBX_MAXINPUTTIME=${ZBX_MAXINPUTTIME:-"300"}
    export PHP_TZ=${PHP_TZ}

    export DB_SERVER_TYPE="POSTGRESQL"
    export DB_SERVER_HOST=${DB_SERVER_HOST}
    export DB_SERVER_PORT=${DB_SERVER_PORT}
    export DB_SERVER_DBNAME=${DB_SERVER_DBNAME}
    export DB_SERVER_SCHEMA=${DB_SERVER_SCHEMA}
    export DB_SERVER_USER=${DB_SERVER_ZBX_USER}
    export DB_SERVER_PASS=${DB_SERVER_ZBX_PASS}
    export ZBX_SERVER_HOST=${ZBX_SERVER_HOST}
    export ZBX_SERVER_PORT=${ZBX_SERVER_PORT}
    export ZBX_SERVER_NAME=${ZBX_SERVER_NAME}

    : ${ZBX_DB_ENCRYPTION:="false"}
    export ZBX_DB_ENCRYPTION=${ZBX_DB_ENCRYPTION,,}
    export ZBX_DB_KEY_FILE=${ZBX_DB_KEY_FILE}
    export ZBX_DB_CERT_FILE=${ZBX_DB_CERT_FILE}
    export ZBX_DB_CA_FILE=${ZBX_DB_CA_FILE}
    : ${ZBX_DB_VERIFY_HOST:="false"}
    export ZBX_DB_VERIFY_HOST=${ZBX_DB_VERIFY_HOST,,}

    export ZBX_VAULT=${ZBX_VAULT}
    export ZBX_VAULTURL=${ZBX_VAULTURL}
    export ZBX_VAULTDBPATH=${ZBX_VAULTDBPATH}
    export VAULT_TOKEN=${VAULT_TOKEN}
    export ZBX_VAULTCERTFILE=${ZBX_VAULTCERTFILE}
    export ZBX_VAULTKEYFILE=${ZBX_VAULTKEYFILE}

    : ${DB_DOUBLE_IEEE754:="true"}
    export DB_DOUBLE_IEEE754=${DB_DOUBLE_IEEE754,,}

    export ZBX_HISTORYSTORAGEURL=${ZBX_HISTORYSTORAGEURL}
    export ZBX_HISTORYSTORAGETYPES=${ZBX_HISTORYSTORAGETYPES:-"[]"}

    export ZBX_SSO_SETTINGS=${ZBX_SSO_SETTINGS:-""}
    export ZBX_SSO_SP_KEY=${ZBX_SSO_SP_KEY}
    export ZBX_SSO_SP_CERT=${ZBX_SSO_SP_CERT}
    export ZBX_SSO_IDP_CERT=${ZBX_SSO_IDP_CERT}

    if [ -n "${ZBX_SESSION_NAME}" ]; then
        cp "$ZABBIX_WWW_ROOT/include/defines.inc.php" "/tmp/defines.inc.php_tmp"
        sed "/ZBX_SESSION_NAME/s/'[^']*'/'${ZBX_SESSION_NAME}'/2" "/tmp/defines.inc.php_tmp" > "$ZABBIX_WWW_ROOT/include/defines.inc.php"
        rm -f "/tmp/defines.inc.php_tmp"
    fi
}

run_zabbix_server() {
    echo "Starting Zabbix frontend..."
    unitd --no-daemon \
            --control unix:$UNIT_UNIXSOCKET_PATH \
            --pid  $UNIT_PID_PATH \
            --user 1001 \
            --group 1001 \
            --log /dev/stdout
}
#################################################

echo "** Deploying Zabbix web-interface (Nginx Unit) with PostgreSQL database"

check_variables
check_db_connect
prepare_web_server
prepare_zbx_web_config
run_zabbix_server

echo "########################################################"

if [ "$1" != "" ]; then
    echo "** Executing '$@'"
    exec "$@"
else
    echo "Unknown instructions. Exiting..."
    exit 1
fi

#################################################
