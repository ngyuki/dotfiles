#!/bin/bash

set -eu

base=$(realpath -- "${BASH_SOURCE[0]}")
base=${base%/*}

cd "$IOS_TFTP_DIR"
sudo -v
sudo in.tftpd -Lscp -u "$USER" . &

cleanup(){
  sudo pkill in.tftpd
}
trap cleanup EXIT ERR

expect -f "$base/ios-download-config.exp"
