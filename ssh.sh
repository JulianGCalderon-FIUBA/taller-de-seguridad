#!/bin/bash

. .env

fail() {
	echo "$*" >&2
	exit 1
}

if [ "$#" -lt 1 ]; then
	fail "missing target"
fi

TARGET=$(echo "$1" | tr '[:lower:]' '[:upper:]')

MAC_ENV="${TARGET}_MAC"
USERNAME_ENV="${TARGET}_USERNAME"

MAC="${!MAC_ENV}"
USERNAME="${!USERNAME_ENV}"

if [ -z "$MAC" ]; then
	fail "missing env var: $MAC_ENV"
fi
if [ -z "$USERNAME" ]; then
	fail "missing env var: $USERNAME_ENV"
fi

echo "Looking for MAC: $MAC"
IP=$(arp -a | grep "$MAC" | cut -d' ' -f 2 | tr -d "()")

if [ -z "$IP" ]; then
		fail "could not find ip"
fi
echo "Found IP: $IP"

ssh "$USERNAME@$IP"
