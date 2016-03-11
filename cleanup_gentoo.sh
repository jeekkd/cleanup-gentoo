#!/bin/bash

# Written by: https://github.com/turkgrb
# Website: https://daulton.ca
# Purpose: Gentoo cleaning script, intended to just be a simple script to run after
# uninstalling things or wanting to clean portage plus a couple extra things like 
# emptying the trash and /var/tmp and /tmp

echo "Cleaning /var/tmp and /tmp..."

rm -rf /var/tmp/portage/*
rm -rf /var/tmp/ccache/*
rm -rf /var/tmp/binpkgs/*
rm -rf /var/tmp/genkernel/*
rm -rf /usr/portage/distfiles/*
rm -rf /usr/portage/packages/*
rm -rf /tmp/*
rm -rf /var/cache/genkernel/*

echo "Cleaning unused libraries and programs..."

emerge -av --depclean
emerge -cav

echo "Cleaning out the trash..."

rm -rf /home/*/.local/share/Trash/*/** &> /dev/null
rm -rf /root/.local/share/Trash/*/** &> /dev/null

echo "Finishing up with checking for and rebuild missing libraries..."

revdep-rebuild -v

echo
echo "Complete!"
