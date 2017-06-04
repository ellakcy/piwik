#!/bin/bash

#Path where all the files will be executed

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done

SCRIPT_PATH="$( cd -P "$( dirname "$SOURCE" )" && pwd )"/..
DOCKER_COMPOSE_YML_PATH="${SCRIPT_PATH}/docker-compose.yml"

# Printing functions
black='\E[30;40m'
red='\E[31;40m'
green='\E[32;40m'
yellow='\E[33;40m'
blue='\E[34;40m'
magenta='\E[35;40m'
cyan='\E[36;40m'
white='\E[37;40m'


cecho ()                     # Color-echo.
                             # Argument $1 = message
                             # Argument $2 = color
{
local default_msg="No message passed."
                             # Doesn't really need to be a local variable.

message=${1:-$default_msg}   # Defaults to default message.
color=${2:-$black}           # Defaults to black, if not specified.

  echo -e "$color"
  echo "$message"
  tput sgr0                      # Reset to normal.

  return
}

cecho "Installation script for piwik + wordpress solution" $magenta

cecho "Deleting Data for a fresh install" $red
sudo rm -rf "${SCRIPT_PATH}/data"

cecho "Setting Up Piwik" $magenta
cecho "Configuring piwik database settings" $cyan

read -p "Insert a password for piwik's database: " PIWIK_MYSQL_ROOT_PASSWORD

cecho "Configuring Email settings for reports." $cyan



#Create .data folder with piwik required stuff
if [ ! -f  ${SCRIPT_PATH} ]; then
 mkdir -p ${SCRIPT_PATH}
fi

read  -p "Instert smtp host: " MAIL_HOST
read -p "Insert smtp port: " MAIL_PORT
read -p "Insert your email username: " MAIL_USER
read -p "Insert your email password: " MAIL_PASS

cat > ${SCRIPT_PATH}/ssmtp.conf << EOF
UseTLS=Yes
UseSTARTTLS=Yes
root=${MAIL_USER}
mailhub=${MAIL_HOST}:${MAIL_PORT}
hostname=${MAIL_HOST}
AuthUser=${MAIL_USER}
AuthPass=${MAIL_PASS}
EOF

echo "www-data:${MAIL_USER}:${MAIL_HOST}:${MAIL_PORT}" >> ${SCRIPT_PATH}/revaliases

cecho "Setting up wordpress" $magenta

cecho "Setting up wordpress' database settings" $magenta

read -p "Insert a password for database ROOT user: " WORDPRESS_MYSQL_ROOT_PASSWORD
read -p "Insert a username for a NEW database user that wordpresss will use for connection: " WORDPRESS_MYSQL_USER
read -p "Insert a password for the DATABASE user created above: " WORDPRESS_MYSQL_PASSWORD

cecho "Setting up wordpress' site settings" $magenta

read -p "Insert a username for the WORDPRESS' admin user: " WORDPRESS_ADMIN_USER
read -p "Insert a password for the WORDPRESS' admin user: " WORDPRESS_ADMIN_PASSWORD
read -p "Insert a your site's url: " WORDPRESS_URL


ENV_COMMAND="PIWIK_MYSQL_ROOT_PASSWORD=${PIWIK_MYSQL_ROOT_PASSWORD}
WORDPRESS_MYSQL_ROOT_PASSWORD=${WORDPRESS_MYSQL_ROOT_PASSWORD}
WORDPRESS_MYSQL_USER=${WORDPRESS_MYSQL_USER}
WORDPRESS_MYSQL_PASSWORD=${WORDPRESS_MYSQL_PASSWORD}
WORDPRESS_ADMIN_USER=${WORDPRESS_ADMIN_USER}
WORDPRESS_ADMIN_PASSWORD=${WORDPRESS_ADMIN_PASSWORD}
WORDPRESS_URL=${WORDPRESS_URL}"

ENV_FILE="${SCRIPT_PATH}/.env"

cecho "Generating Enviromental variables file: " $magenta
echo "${ENV_COMMAND}" > ${ENV_FILE}
if [ -f ${ENV_FILE} ]; then
  cecho "File ${ENV_FILE} generated" $green
fi

COMMAND="docker-compose -f ${DOCKER_COMPOSE_YML_PATH}"

STARTUP_SCRIPT_PATH="${SCRIPT_PATH}/start.sh"
STOP_SCRIPT_PATH="${SCRIPT_PATH}/stop.sh"
BACKUP_SCRIPT_PATH="${SCRIPT_PATH}/backup.sh"

echo "${COMMAND} up -d" > ${STARTUP_SCRIPT_PATH}
chmod u+x ${STARTUP_SCRIPT_PATH}
cecho "Startup script generated" $green

echo $COMMAND" stop " > ${STOP_SCRIPT_PATH}
chmod u+x ${STOP_SCRIPT_PATH}
cecho "Stop script generated" $green

echo "env ${ENV_COMMAND} ${SCRIPT_PATH}/scripts/pre-backup" > ${BACKUP_SCRIPT_PATH}
chmod u+x ${BACKUP_SCRIPT_PATH}
cecho "Backup script generated" $green

echo "In order to start up the containers run: "
cecho "${STARTUP_SCRIPT_PATH}" $green

echo "You can stop the containers via:"
cecho "${STOP_SCRIPT_PATH}" $green

echo "You can perform a full backup via:"
cecho "sudo ${BACKUP_SCRIPT_PATH}" $green
