#!/bin/bash -eu

TF_VERSION=1.3.2
PLATFORM=linux_amd64

TF_URL="https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_${PLATFORM}.zip"
TF_DL_DST_PATH="/tmp/terraform_${TF_VERSION}_${PLATFORM}.zip"

echo "[INFO] download terraform v${TF_VERSION}..."
if [[ `which curl 2>/dev/null` ]]; then
  curl -o ${TF_DL_DST_PATH} -L ${TF_URL}
elif [[ `which wget 2>/dev/null` ]]; then
  wget -O ${TF_DL_DST_PATH} ${TF_URL}
else
  echo "[ERROR] There are not either of curl and wget."
  exit 1
fi

echo "[INFO] unzip terraform..."
unzip ${TF_DL_DST_PATH} -d /tmp


if [[ "$PATH" == *${HOME}/bin* ]]; then
  TF_BIN_DST_DIR=${HOME}/bin
  echo "[INFO] mv to ${TF_BIN_DST_DIR}..."
  if [ ! -d ${TF_BIN_DST_DIR} ]; then
    echo "[INFO] notice: create ${TF_BIN_DST_DIR}"
    mkdir -p ${TF_BIN_DST_DIR}
  fi
elif [[ "$PATH" == *${HOME}/.local/bin* ]]; then
  TF_BIN_DST_DIR=${HOME}/.local/bin
  echo "[INFO] mv to ${TF_BIN_DST_DIR}..."
  if [ ! -d ${TF_BIN_DST_DIR} ]; then
    echo "[INFO] notice: create ${TF_BIN_DST_DIR}"
    mkdir -p ${TF_BIN_DST_DIR}
  fi
else
  # 仕方ないので /usr/local/bin へ
  if [ "`whoami`" != "root" ]; then
    echo "[ERROR] Require root privilege for mv to /usr/local/bin"
    exit 1
  fi
  TF_BIN_DST_DIR=/usr/local/bin
  echo "[INFO] mv to ${TF_BIN_DST_DIR}..."
fi
mv /tmp/terraform ${TF_BIN_DST_DIR}

if [[ `which terraform 2>/dev/null` ]]; then
  echo "[INFO] The process has succeeded. Now you can execute \`terraform\` command."
fi
