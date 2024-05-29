<?php
// Zabbix GUI configuration file.

$DB['TYPE']     = getenv('DB_SERVER_TYPE');
$DB['SERVER']   = getenv('DB_SERVER_HOST');
$DB['PORT']     = getenv('DB_SERVER_PORT');
$DB['DATABASE'] = getenv('DB_SERVER_DBNAME');
$DB['USER']     = (! getenv('VAULT_TOKEN') || ! getenv('ZBX_VAULTURL')) ? getenv('DB_SERVER_USER') : '';
$DB['PASSWORD'] = (! getenv('VAULT_TOKEN') || ! getenv('ZBX_VAULTURL')) ? getenv('DB_SERVER_PASS') : '';

// Schema name. Used for PostgreSQL.
$DB['SCHEMA']			= getenv('DB_SCHEMA') ? getenv('DB_SCHEMA'): 'public';

// Used for TLS connection.
$DB['ENCRYPTION']		= false;
$DB['KEY_FILE']			= '';
$DB['CERT_FILE']		= '';
$DB['CA_FILE']			= '';
$DB['VERIFY_HOST']		= false;
$DB['CIPHER_LIST']		= '';

// Vault configuration. Used if database credentials are stored in Vault secrets manager.
$DB['VAULT_URL']		= '';
$DB['VAULT_DB_PATH']	= '';
$DB['VAULT_TOKEN']		= '';

// Use IEEE754 compatible value range for 64-bit Numeric (float) history values.
// This option is enabled by default for new Zabbix installations.
// For upgraded installations, please read database upgrade notes before enabling this option.
$DB['DOUBLE_IEEE754']	= true;

// Uncomment and set to desired values to override Zabbix hostname/IP and port.
$ZBX_SERVER			    = getenv('ZBX_SERVER_HOST') ? getenv('ZBX_SERVER_HOST') : 'zabbix-server';
$ZBX_SERVER_PORT		= getenv('ZBX_SERVER_PORT') ? getenv('ZBX_SERVER_PORT') : '10051';

$ZBX_SERVER_NAME		= getenv('ZBX_SERVER_NAME') ? getenv('ZBX_SERVER_NAME') : 'zabbix-agent';

$IMAGE_FORMAT_DEFAULT	= IMAGE_FORMAT_PNG;

// Uncomment this block only if you are using Elasticsearch.
// Elasticsearch url (can be string if same url is used for all types).
//$HISTORY['url'] = [
//	'uint' => 'http://localhost:9200',
//	'text' => 'http://localhost:9200'
//];
// Value types stored in Elasticsearch.
//$HISTORY['types'] = ['uint', 'text'];

// Used for SAML authentication.
// Uncomment to override the default paths to SP private key, SP and IdP X.509 certificates, and to set extra settings.
//$SSO['SP_KEY']			= 'conf/certs/sp.key';
//$SSO['SP_CERT']			= 'conf/certs/sp.crt';
//$SSO['IDP_CERT']		= 'conf/certs/idp.crt';
//$SSO['SETTINGS']		= [];

