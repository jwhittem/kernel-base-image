#!/bin/bash

DEBIAN_MAJOR_VERSION=13
SOURCE_ISO_URL=$(curl -s https://cdimage.debian.org/cdimage/release/current/amd64/iso-cd/ | grep -o '<a[^>]*href="[^"]*"' | sed -E 's/.*href="([^"]*)".*/\1/' | uniq | grep debian-$DEBIAN_MAJOR_VERSION)

packer init -upgrade base-kvm.pkr.hcl
packer build -var "source_iso=$SOURCE_ISO_URL" base-kvm.pkr.hcl
