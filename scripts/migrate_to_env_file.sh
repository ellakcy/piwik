#!/bin/bash

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done

SCRIPT_PATH="$( cd -P "$( dirname "$SOURCE" )" && pwd )"/..

# https://stackoverflow.com/questions/44355112/bash-replace-character-into-separated-values
grep -o -P "(\w*_?)*=(\"|\').*(\"|\')" ${SCRIPT_PATH}/start.sh | sed 's/"//g' > ${SCRIPT_PATH}/run.env
