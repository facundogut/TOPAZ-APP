#!/bin/sh
LANG=es_ES.ISO-8859-1
LANGVAR=es_ES.ISO-8859-1
SUPPORTED=es_ES:es:$SUPPORTED
export LANG LANGVAR SUPPORTED
#TITLE TOPAZ ON EAP Wildfly 10.0.0.Final $0
export JAVA_HOME="{{ param_files.runtopaz.java_home | default('/usr/java/jdk1.8.0_251-amd64')}}"
echo "Setting java configuration options and propeties"
export JAVA_OPTS="{{param_files.runtopaz.java_opts}}"
export JAVA_OPTS="$JAVA_OPTS -Duser.language=es"
export JAVA_OPTS="$JAVA_OPTS -Djboss.as.management.blocking.timeout=3500"
export JAVA_OPTS="$JAVA_OPTS -Dhibernate.dialect=org.hibernate.dialect.SQLServer2012Dialect"
export JAVA_OPTS="$JAVA_OPTS -Djava.net.preferIPv4Stack=true"
export JAVA_OPTS="$JAVA_OPTS -Dfile.encoding=ISO-8859-1"
export JAVA_OPTS="$JAVA_OPTS -Djboss.modules.system.pkgs=org.jboss.byteman,com.sun.crypto.provider"
#export JAVA_OPTS="$JAVA_OPTS -Djavax.net.debug=all"
export JAVA_OPTS="$JAVA_OPTS -Duser.country=ES -Duser.language=es -Duser.region=ES"
export JAVA_OPTS="$JAVA_OPTS -Djboss.server.temp.dir={{ jboss_server_temp_dir }}"

# Security
export JAVA_OPTS="$JAVA_OPTS -Djavax.net.ssl.trustStore=/etc/java/security/cacerts"
export JAVA_OPTS="$JAVA_OPTS -Djava.security.properties=/etc/java/security/java.security"

# APM - ELK
export JAVA_OPTS="$JAVA_OPTS -javaagent:/opt/apm/elastic-apm-agent.jar"
export JAVA_OPTS="$JAVA_OPTS -Delastic.apm.service_name={{ inventory_hostname }}"
export JAVA_OPTS="$JAVA_OPTS -Delastic.apm.environment={{ imp_repos_config_branch }}-core"
export JAVA_OPTS="$JAVA_OPTS -Delastic.apm.application_packages=org.example,org.another.example"
export JAVA_OPTS="$JAVA_OPTS -Delastic.apm.server_url=http://els-apm.nbch.com.ar"
export JAVA_OPTS="$JAVA_OPTS -Delastic.apm.instrument_ancient_bytecode=true"

# Se cuenta con dos xml de configuración preparados según la base de datos que se deseea utilizar y si se quiere habilitar conector HTTPS.
CONFIG_JBOSS={{ param_files.standalone_full_ha.name | default('standalone-full-ha.xml') }}

#Direccion del servidor
JBOSS_BIND_ADDRESS="{{ inventory_hostname }}"

# Oracle URL connection
TOPAZ_DATABASE_URI="jdbc:jtds:sqlserver://{{topaz_database.hostname}}:{{topaz_database.port}}/{{ topaz_database.dbname | default('infra') }}{{ topaz_database_options | default('') }}"
TOPAZ_DATABASE_URI_ODEBITOS="jdbc:jtds:sqlserver://{{topaz_odebitos.hostname}}:{{topaz_odebitos.port}}/{{ topaz_odebitos.dbname | default('infra') }}"

JBOSS_ROOT_DIR=/topaz/jboss

#Nivel del log
TOPAZ_LOG_VERBOSE={{ param_files.runtopaz.level_log }}

# Path base donde se tendra las carpetas "deployments, tem, data" (relative-to).
JBOSS_BASE_DIR="$JBOSS_ROOT_DIR/standalone"
JBOSS_DEPLOYMENTS_DIR="$JBOSS_BASE_DIR"

# Log servidor
TOPAZ_LOG_DIR="/topaz/logs/topaz"
JBOSS_SERVER_LOG_DIR="/topaz/logs/jboss"

# Eliminar lo archivos que genera el server al hacer deploy
echo "Eliminando archivos de deploy "
rm $JBOSS_BASE_DIR/deployments/*.deployed
rm $JBOSS_BASE_DIR/deployments/*.dodeploy
rm $JBOSS_BASE_DIR/deployments/*.isdeploying
rm $JBOSS_BASE_DIR/deployments/*.skipdeploy
rm $JBOSS_BASE_DIR/deployments/*.failed
rm $JBOSS_BASE_DIR/deployments/*.isundeploying
rm $JBOSS_BASE_DIR/deployments/*.undeployed
rm $JBOSS_BASE_DIR/deployments/*.pending


# Crear el archivo topaz.ear.dodeploy porque el servidor no realiza el deploy automáticamente a la carpeta topaz.ear
touch $JBOSS_BASE_DIR/deployments/topaz.ear.dodeploy
# Crear el archivo jDesktop.war.dodeploy porque el servidor no realiza el deploy automáticamente a la carpeta jDesktop.war
touch $JBOSS_BASE_DIR/deployments/jDesktop.war.dodeploy

# Crear el archivo Topaz-Posicion.war
touch $JBOSS_BASE_DIR/deployments/Topaz-Posicion.war.dodeploy

echo "Levantando el servicio con los siguientes parametros:"
echo " "
#esto no esta
NODE_ID={{ENVIROMENT_ID}}{{ inventory_hostname_short[-2:] }}
NODE_NAME=node$NODE_ID

# Para producción el --debug no debe ir

./standalone.sh  --debug -Djava.awt.headless=true -Djboss.bind.address.management=$JBOSS_BIND_ADDRESS -b $JBOSS_BIND_ADDRESS \
--server-config=$CONFIG_JBOSS -Dtopaz.log.file.path=$TOPAZ_LOG_DIR \
-Dtopaz.log.verbose=$TOPAZ_LOG_VERBOSE \
-Dtopaz.database.uri=$TOPAZ_DATABASE_URI \
-Dtopaz.database.uri.odebitos=$TOPAZ_DATABASE_URI_ODEBITOS \
-Djboss.server.log.dir=$JBOSS_SERVER_LOG_DIR \
-Djboss.bind.address=$JBOSS_BIND_ADDRESS \
-Djboss.bind.address.management=$JBOSS_BIND_ADDRESS \
-Djboss.as.management.blocking.timeout=3500 \
-Djboss.server.deployments.dir=$JBOSS_DEPLOYMENTS_DIR \
-Djboss.node.name=$NODE_NAME \
-Dtopaz.cluster.nodeid=$NODE_ID \
-Djboss.bind.address.private=$JBOSS_BIND_ADDRESS
