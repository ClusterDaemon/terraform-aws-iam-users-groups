#!/bin/bash
set -e

keyring=$(mktemp)
trap 'rm -f "$keyring"' EXIT

base64 -d <<<$1 | gpg --import --no-default-keyring --keyring $keyring &> /dev/null

keys=$(gpg --list-keys --with-colons --no-default-keyring --keyring $keyring)

email=$(awk -F: '/^uid:/ { print $10 }' <<<"$keys")

base64 -d <<<$2 | \
gpg --yes --batch --encrypt --recipient "$email" --trust-model always --no-default-keyring --keyring $keyring | \
base64 | \
jq -R -s '{encrypted_base64: .}'
