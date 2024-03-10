#!/bin/bash
set -euo pipefail

SCRIPT_DIR=$(cd $(dirname $0); pwd)

PROJECT_ROOT_PATH=$(cd $(dirname $0); pwd)

BUILD_DIR_PATH="${PROJECT_ROOT_PATH}/build"

REUQIREMENTS_PATH="${BUILD_DIR_PATH}/requirements.txt"
VIRTUALENV_PATH="${BUILD_DIR_PATH}/lambda_layer.venv"
LAYER_PATH="${BUILD_DIR_PATH}/lambda_layer.layer"


cd ${PROJECT_ROOT_PATH}

mkdir -p ${BUILD_DIR_PATH} 1>&2

poetry export -f requirements.txt --without-hashes > ${REUQIREMENTS_PATH}

python -m venv ${VIRTUALENV_PATH} 1>&2
source ${VIRTUALENV_PATH}/bin/activate 1>&2
pip3 install -r ${REUQIREMENTS_PATH} -t ${LAYER_PATH}/python --no-cache-dir 1>&2
deactivate 1>&2


PATH_ESCAPED=$(echo ${LAYER_PATH} | sed 's/"/\\"/g')

echo '{"path": "'${PATH_ESCAPED}'"}'
