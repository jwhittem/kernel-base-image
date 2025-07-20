#!/bin/bash

dpkg-reconfigure openssh-server

if [ -f /etc/tailscale.key ]; then
  KEY=$(cat /etc/tailscale.key)
  curl -fsSL https://pkgs.tailscale.com/stable/debian/bookworm.noarmor.gpg | tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null
  curl -fsSL https://pkgs.tailscale.com/stable/debian/bookworm.tailscale-keyring.list | tee /etc/apt/sources.list.d/tailscale.list
  apt update
  apt install tailscale -y
  tailscale up --auth-key $KEY
  shred /etc/tailscale.key && rm -rf /etc/tailscale.key
fi

reboot
