# kube-base-image

This was created to make building VM base images for Kernel builds.

Available virtual machine outputs are:

- KVM

## building

You will need KVM, and packer installed to build.  Simply run `make` to build the image.  Image will be build in output directory.

## base image build

Overview of the image configuration:

- Installs [cloud-init] for run once tasks, and for future automation
- Allows user provided `authorized_keys` file applied to user `debian` by placing it in `files/` prior to build
- Displays ip address at login screen
- Enables serial console access

*Default username / password is 'debian' this is something you'll want to change once the machine is setup.*

The distribution is the net install of Debian. 

Packer uses an automatic answer file seen at [preseed](http/preseed.cfg), this is referenced during the initial OS configuration.  VNC is used to alter the VM's linux boot parameters, then this preseed file is served via http, and will automate the install of the OS.  
