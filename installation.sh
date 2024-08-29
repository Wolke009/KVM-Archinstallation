#!/bin/sh
#KVM-Installation

# Ensure the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script as root."
  exit 1
fi

echo "Updating package database and system..."
pacman -Syu --noconfirm

echo "Installing necessary packages..."
pacman -S --noconfirm qemu qemu-arch-extra virt-manager virt-viewer dnsmasq vde2 bridge-utils libvirt libvirt-glib openbsd-netcat ebtables iptables

echo "Enabling and starting the libvirtd service..."
systemctl enable libvirtd.service
systemctl start libvirtd.service

echo "Loading the KVM kernel module..."
modprobe kvm
modprobe kvm-intel  # For Intel processors
modprobe kvm-amd    # For AMD processors

# Check if the kernel module was successfully loaded
if lsmod | grep -q "kvm"; then
  echo "KVM module loaded successfully."
else
  echo "Error: KVM module failed to load."
  exit 1
fi

echo "Adding the user to the libvirt group..."
usermod -aG libvirt $(logname)

echo "Setting up network configuration for libvirt..."
virsh net-define /etc/libvirt/qemu/networks/default.xml
virsh net-autostart default
virsh net-start default

echo "KVM/QEMU has been successfully installed and configured."
echo "Please log out and log back in for group membership changes to take effect."
