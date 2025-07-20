#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

sed -i 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=1/' /etc/default/grub
update-grub

echo "localepurge	localepurge/use-dpkg-feature	boolean	true" | debconf-set-selections
echo "localepurge	localepurge/nopurge	multiselect	en, en_US.UTF-8"  | debconf-set-selections

apt-get update
apt-get install -y --no-install-recommends \
    apt-transport-https \
    autoconf \
    bc \
    bison \
    build-essential \
    ca-certificates \
    cloud-guest-utils \
    cloud-init \
    cscope \
    curl \
    dkms \
    exuberant-ctags \
    flex \
    gawk \
    gcc \
    git \
    gnupg \
    libelf-dev \
    libiberty-dev \
    libncurses-dev \
    libpci-dev \
    libssl-dev \
    libudev-dev \
    linux-source \
    llvm \
    localepurge \
    lsb-release \
    make \
    openssl \
    qemu-guest-agent \
    vim \
    wget \
    xz-utils

if [ -f tailscale.key ]; then
  KEY=$(cat tailscale.key)
  curl -fsSL https://pkgs.tailscale.com/stable/debian/bookworm.noarmor.gpg | tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null
  curl -fsSL https://pkgs.tailscale.com/stable/debian/bookworm.tailscale-keyring.list | tee /etc/apt/sources.list.d/tailscale.list
  apt update
  apt install tailscale
  tailscale up --auth-key $KEY
fi

install -m 644  /home/debian/kernel-base-image/files/vimrc /root/.vimrc
install -m 644 -D /home/debian/kernel-base-image/files/no-clear.conf /etc/systemd/system/getty@tty1.service.d/no-clear.conf
install -m 644 /home/debian/kernel-base-image/files/1_debian_config.cfg /etc/cloud/cloud.cfg.d/1_debian_config.cfg
install -m 644 /home/debian/kernel-base-image/files/interfaces /etc/network/interfaces
install -m 644 /home/debian/kernel-base-image/files/issue /etc/issue
install -m 755 -D /home/debian/kernel-base-image/files/run-once.sh /var/lib/cloud/scripts/per-instance/run-once.sh

if test -f /home/debian/kernel-base-image/files/authorized_keys; then
    install -m 644 -D -o debian -g debian /home/debian/kernel-base-image/files/authorized_keys /home/debian/.ssh/authorized_keys
fi

systemctl add-wants multi-user.target cloud-init.target
systemctl enable qemu-guest-agent
systemctl enable --now serial-getty@ttyS0.service

apt-get install --yes deborphan
apt-get autoremove \
  console-setup \
  $(deborphan) \
  deborphan \
  dictionaries-common \
  iamerican \
  ibritish \
  localepurge \
  task-english \
  tasksel \
  tasksel-data \
  --purge --yes

apt-get clean

find \
   /var/cache/apt \
   -mindepth 1 -print -delete

rm -vf \
   /etc/adjtime \
   /etc/ssh/*key* \
   /var/cache/ldconfig/aux-cache \
   /var/lib/systemd/random-seed \
   ~/.bash_history \
   ${SUDO_USER}/.bash_history 
   
rm -rf /home/debian/kernel-base-image
fstrim --all --verbose
