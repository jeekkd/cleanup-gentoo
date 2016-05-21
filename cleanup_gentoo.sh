#!/bin/bash
# Written by: https://github.com/turkgrb
# Website: https://daulton.ca
# Purpose: Gentoo cleaning script, intended to just be a simple script to run after
# uninstalling things or wanting to clean portage plus a couple extra things like 
# emptying the trash and /var/tmp and /tmp

echo "Enter the user you wish to clean for: "
read entered_user

echo "* Cleaning /var/tmp and /tmp..."
rm -rf /var/tmp/portage/*
rm -rf /var/tmp/ccache/*
rm -rf /var/tmp/binpkgs/*
rm -rf /var/tmp/genkernel/*
rm -rf /usr/portage/distfiles/*
rm -rf /usr/portage/packages/*
rm -rf /tmp/*
rm -rf /var/cache/genkernel/*

echo "* Cleaning cache that was accessed 7 days ago or more"
find /home/$entered_user/.cache/ -type f -atime +7 | xargs rm -Rf
find /home/$entered_user/.cache/google-chrome/Default/Cache/* -type f -atime +2 | xargs rm -Rf
find /home/$entered_user/.cache/google-chrome/Default/Media\ Cache/* -type f -atime +2 | xargs rm -Rf
find /home/$entered_user/.cache/google-chrome/Default/Local\ Storage/* -type f -atime +2 | xargs rm -Rf
find /home/$entered_user/.cache/google-chrome/Default/IndexedDB/* -type f -atime +2 | xargs rm -Rf
find /home/$entered_user/.cache/mozilla/firefox/*/cache2/entries/* -type f -atime +2 | xargs rm -Rf
find /home/$entered_user/.cache/mozilla/firefox/*/thumbnails/* -type f -atime +2 | xargs rm -Rf
find /home/$entered_user/.cache/fontconfig/* -type f -atime +2 | xargs rm -Rf
find /home/$entered_user/.cache/keyring-*/* -type f -atime +2 | xargs rm -Rf
find /home/$entered_user/.mozilla/firefox/Crash\ Reports/* -type f -atime +2 | xargs rm -Rf
find /home/$entered_user/.thumbnails/normal/* -type f -atime +2 | xargs rm -Rf

echo "* Cleaning unused libraries and programs..."
emerge -av --depclean
emerge -cav

echo "* Cleaning out the trash..."
rm -rf /home/*/.local/share/Trash/*/** &> /dev/null
rm -rf /root/.local/share/Trash/*/** &> /dev/null

echo "* Checking system for compliance with Gentoo Linux Security Advisories"

good_result="This system is not affected by any of the listed GLSAs"
glsa_check_result=`glsa-check -t all`
if [ "$(diff -q $glsa_check_result $good_result 2>&1)" = "" ] ; then
    glsa-check -f all
fi

echo "* Removing foreign man pages"
find /usr/share/man -type d -not -name man*

echo "* Removing gtk docs"
rm -rf /usr/share/gtk-doc

echo "* Removing locale files"
find /usr/share/locale/* -type d | xargs rm -rf

echo "* Removing unused packages"
eclean -d packages

echo "* Checking for packages with changed use flags"
emerge --ask --update --changed-use --deep @world

echo "Removing distfiles"
rm /var/portage/distfiles/*

echo "* Removing python compiled files and tests"
find /usr/lib/python* -name \*.py? -delete
find /usr/lib/python* -type d -name __pycache__ -delete
find /usr/lib/portage -name \*.py? -delete
find /usr/lib/portage -type d -name __pycache__ -delete
rm -rf /usr/lib/python*/test

echo "* Disabling python bytecode generation"
echo "PYTHONDONTWRITEBYTECODE=1" > /etc/env.d/99python
env-update && source /etc/profile

echo "* Removing binutils info pages"
rm -rf binutils-data/*/*/info

echo "* Removing config-archive"
rm -rf /etc/config-archive

isInstalledRotate=$(equery list "*" | grep logrotate)
if [[ $isInstalledRotate = *[!\ ]* ]]; then
	echo "* Logrotate is installed already, skipping"
else
	echo "* Would you like to install logrotate to keep your logs clean? YES/NO"
	read logrotate_answer
	if [[ $logrotate_answer == "YES" || $logrotate_answer == "yes" ]] ; then
		emerge app-admin/logrotate
	fi
fi

if [[ $isInstalledRotate = *[!\ ]* ]]; then
    echo "* Running a forced logrotate and cleaning logs"
   logrotate --force /etc/logrotate.conf
	find /var/log/ -name '*[0-5]*' -exec rm {} \;
fi

echo "* Finishing up with checking for and rebuild missing libraries..."
revdep-rebuild -v

echo
echo "* Complete!"
