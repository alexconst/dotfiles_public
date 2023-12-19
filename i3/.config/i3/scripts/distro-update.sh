#!/bin/sh

# Check if the Linux distro is Arch or Debian
if [ -f /etc/debian_version ]; then
    bash $HOME/.config/i3/scripts/distro-debian.sh
elif [ -f /etc/arch-release ]; then
    python3 $HOME/.config/i3/scripts/distro-arch.py
fi

