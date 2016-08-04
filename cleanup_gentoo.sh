#!/usr/bin/env bash
# Written by: https://gitlab.com/u/huuteml
# Website: https://daulton.ca
# Purpose: To be a simple script to run after uninstalling packages to clean the dependencies or wanting to 
# clean portages left over ebuilds from previous emerges. There is a couple extra handy things like emptying 
# the trash, cleaning /var/tmp and /tmp, checks the system for compliance with Gentoo Linux Security 
# Advisories and so forth.

user=$(who am i | awk '{print $1}')

echo "* Cleaning /var/tmp and /tmp..."
rm -rf /var/tmp/portage/*
rm -rf /var/tmp/ccache/*
rm -rf /var/tmp/binpkgs/*
rm -rf /var/tmp/genkernel/*
rm -rf /usr/portage/distfiles/*
rm -rf /usr/portage/packages/*
rm -rf /tmp/*
rm -rf /var/cache/genkernel/*
echo

echo "* Cleaning browser and other caches..."
rm -rf  /home/$user/.cache/chromium/Default/*
rm /home/$user/.mozilla/firefox/*.default/*.sqlite /home/$user/.mozilla/firefox/*default/sessionstore.js
rm -rf /home/$user/.cache/mozilla/firefox/*.default/*
echo

echo "* Cleaning unused libraries and programs..."
emerge -av --depclean
emerge -cav
echo

echo "* Cleaning out the trash..."
rm -rf /home/*/.local/share/Trash/*/** &> /dev/null
rm -rf /root/.local/share/Trash/*/** &> /dev/null
echo

echo "* Checking system for compliance with Gentoo Linux Security Advisories"
good_result="This system is not affected by any of the listed GLSAs"
glsa_check_result=$(glsa-check -t all)
if [ "$(diff -q $glsa_check_result $good_result 2>&1)" = "" ] ; then
    glsa-check -f all
fi
echo

echo "* Removing foreign man pages"
find /usr/share/man -type d -not -name "man*"
echo

echo "* Removing gtk docs"
rm -rf /usr/share/gtk-doc
echo

echo "* Removing locale files"
find /usr/share/locale/* -type d | xargs rm -rf
echo

echo "* Removing unused packages"
eclean -d packages
echo

echo "* Checking for packages with changed use flags"
emerge --ask --update --changed-use --deep @world
echo

echo "Removing distfiles"
rm /var/portage/distfiles/*
echo

echo "* Disabling python bytecode generation"
echo "PYTHONDONTWRITEBYTECODE=1" > /etc/env.d/99python
env-update && source /etc/profile

echo
echo "* Removing config-archive"
rm -rf /etc/config-archive

isInstalledRotate=$(equery list "*" | grep logrotate)
if [[ $isInstalledRotate = *[!\ ]* ]]; then
	echo "* Running a forced logrotate and cleaning logs"
	logrotate --force /etc/logrotate.conf
	find /var/log/ -name '*[0-5]*' -exec rm {} \;
else
	echo "* Would you like to install logrotate to keep your logs clean? YES/NO"
	read -r logrotate_answer
	if [[ $logrotate_answer == "YES" || $logrotate_answer == "yes" ]] ; then
		emerge app-admin/logrotate
	fi
fi

echo
echo "Checking for obselete packages..."
eix-test-obsolete

echo
echo "* Finishing up with checking for and rebuild missing libraries..."
revdep-rebuild -v

echo
echo "* Complete!"
