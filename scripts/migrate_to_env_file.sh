#!/bin/bash

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done

SCRIPT_PATH="$( cd -P "$( dirname "$SOURCE" )" && pwd )"/..


echo "Generating .env file"
# https://stackoverflow.com/questions/44355112/bash-replace-character-into-separated-values
grep -o -P "(\w*_?)*=(\"|\').*(\"|\')" ${SCRIPT_PATH}/start.sh | sed 's/"//g' > ${SCRIPT_PATH}/.env

echo "Regenerating start & stop scripts"
cp ${SCRIPT_PATH}/start.sh ${SCRIPT_PATH}/start.sh.bak
cp ${SCRIPT_PATH}/stop.sh ${SCRIPT_PATH}/stop.sh.bak

DOCKER_COMPOSE_YML_PATH="${SCRIPT_PATH}/docker-compose.yml"
COMMAND="docker-compose -f ${DOCKER_COMPOSE_YML_PATH}"

STARTUP_SCRIPT_PATH="${SCRIPT_PATH}/start.sh"
STOP_SCRIPT_PATH="${SCRIPT_PATH}/stop.sh"

echo "${COMMAND} up -d" > ${STARTUP_SCRIPT_PATH}
echo $COMMAND" stop " > ${STOP_SCRIPT_PATH}
