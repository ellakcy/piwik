#!/bin/bash

PIWIK_PATH="../.data/piwik"

#Create .data folder with piwik required stuff
if [ ! -f  ${PIWIK_PATH} ]; then
 mkdir -p ${PIWIK_PATH}
fi

read  -p "Instert smtp host: " MAIL_HOST
read -p "Insert smtp port: " MAIL_PORT
read -p "Insert your email username: " MAIL_USER
read -p "Insert your email password: " MAIL_PASS

cat > ${PIWIK_PATH}/ssmtp.conf << EOF
UseTLS=Yes
UseSTARTTLS=Yes
root=${MAIL_USER}
mailhub=${MAIL_HOST}:${MAIL_PORT}
hostname=${MAIL_HOST}
AuthUser=${MAIL_USER}
AuthPass=${MAIL_PASS}
EOF

echo "www-data:${MAIL_USER}:${MAIL_HOST}:${MAIL_PORT}" >> ${PIWIK_PATH}/revaliases
