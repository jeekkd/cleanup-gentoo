#!/usr/bin/env bash
# Written by: 	Daulton
# Website: 		https://daulton.ca
# Repository:	https://github.com/jeekkd
#
# Purpose: To be a simple script to run after uninstalling packages to clean the dependencies or wanting to 
# clean portages left over ebuilds from previous emerges. There is a couple extra handy things like emptying 
# the trash, cleaning /var/tmp and /tmp, checks the system for compliance with Gentoo Linux Security 
# Advisories and so forth.

user=$(who am i | awk '{print $1}')

echo "* Cleaning /var/tmp, /tmp, etc..."
rm -rf /var/tmp/portage/*
rm -rf /var/tmp/ccache/*
rm -rf /var/tmp/binpkgs/*
rm -rf /var/tmp/genkernel/*
rm -rf /tmp/*
rm -rf /var/cache/genkernel/*
echo

echo "* Clean contents of /usr/portage/distfiles? Y/N"
echo "Source code archives and distribution files for older versions of programs are not automatically removed when a new version is emerged. "
read -r cleanDistfiles
if [[ $cleanDistfiles == "Y" ]] || [[ $cleanDistfiles == "y" ]]; then
	rm -rf /usr/portage/distfiles/*
fi

echo
echo "* Remove contents of /usr/portage/packages? Y/N"
echo "As with distribution files, binary packages are not automatically removed. "
read -r cleanPackages
if [[ $cleanPackages == "Y" ]] || [[ $cleanPackages == "y" ]]; then
	rm -rf /usr/portage/packages/*
fi

echo
echo "Enter kernel module cleaning menu? Y/N"
echo "Module files installed after kernel compilation are not tracked by the package manager an thus are not deleted after being unmerged. "
read -r cleanModules
if [[ $cleanModules == "Y" ]] || [[ $cleanModules == "y" ]]; then
	echo "Select each entry by the its number to delete it then when done type exit to exit"
	echo
	for (( ; ; )); do
		ls -l /lib64/modules/ | sed 1d | cat -n
		deleteConfirmation=
		read -r moduleSelection
		if [[ $moduleSelection == "exit" ]] || [[ $moduleSelection == "Exit" ]]; then
			echo "Exiting now"
			break
		fi
		moduleToDelete=$(ls /lib64/modules/ | sed -n $moduleSelection\p)
		echo
		echo "Are you sure you want to delete the modules for $moduleToDelete? Y/N or exit"
		read -r deleteConfirmation
		if [[ $deleteConfirmation == "Y" ]] || [[ $deleteConfirmation == "y" ]]; then
			echo "* Deleting modules.. please wait"
			rm -rf /lib64/modules/"$moduleToDelete"/
			if [ $? -eq 0 ]; then
				echo "Deletion complete.."
				echo
				echo "Select each entry to delete then when done type exit at any time to exit"
				echo
			fi
		elif [[ $deleteConfirmation == "N" ]] || [[ $deleteConfirmation == "n" ]]; then
			echo "Returning back.."
		elif [[ $deleteConfirmation == "exit" ]] || [[ $deleteConfirmation == "Exit" ]]; then
			echo "Exiting now"
			break
		else
			echo "Exiting now"
			break
		fi
	done
fi

echo
echo "Enter kernel sources cleaning menu? Y/N"
echo "As with module files, kernel object files are not removed by the package manager. "
read -r cleanKernels
if [[ $cleanKernels == "Y" ]] || [[ $cleanKernels == "y" ]]; then
	echo "Select each entry to delete then when done type exit at any time to exit"
	echo
	for (( ; ; )); do
		ls -l --hide=linux /usr/src/ | sed 1d | cat -n
		deleteConfirmation=
		read -r kernelSelection
		if [[ $kernelSelection == "exit" ]] || [[ $kernelSelection == "Exit" ]]; then
			echo "Exiting now"
			break
		fi
		kernelToDelete=$(ls -l --hide=linux /usr/src/ | sed 1d | awk '/linux/{print $9}' | sed -n $kernelSelection\p)
		echo
		echo "Are you sure you want to delete the kernel $kernelToDelete? Y/N or exit"
		read -r deleteConfirmation
		if [[ $deleteConfirmation == "Y" ]] || [[ $deleteConfirmation == "y" ]]; then
			rm -rf /usr/src/"$kernelToDelete"/
			if [ $? -eq 0 ]; then
				echo "Deletion complete.."
				echo
				echo "Select each entry to delete then when done type exit at any time to exit"
				echo
			fi
		elif [[ $deleteConfirmation == "N" ]] || [[ $deleteConfirmation == "n" ]]; then
			echo "Returning back.."
		elif [[ $deleteConfirmation == "exit" ]] || [[ $deleteConfirmation == "Exit" ]]; then
			echo "Exiting now"
			break
		else
			echo "Exiting now"
			break
		fi
	done
fi

echo
echo "Clean firefox and chromium browser caches? Y/N"
read -r browserClean
if [[ $browserClean == "Y" ]] || [[ $browserClean == "y" ]]; then
	echo "* Cleaning browser and other caches..."
	rm -rf  /home/$user/.cache/chromium/Default/*
	rm /home/$user/.mozilla/firefox/*.default/*.sqlite /home/$user/.mozilla/firefox/*default/sessionstore.js
	rm -rf /home/$user/.cache/mozilla/firefox/*.default/*
	echo
fi

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
