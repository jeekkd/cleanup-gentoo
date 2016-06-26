Purpose
=====

The purpose of this script is to just be a simple script to run after uninstalling packages to clean the
dependencies or wanting to clean portages leftovers from previous emerges. There is a couple extra 
handy things like emptying the trash, cleaning /var/tmp and /tmp, checks the system for compliance with
Gentoo Linux Security Advisories, empty browser cache, etc.

How to use
====
> - First we must change the scripts permissions. This will make the script readable, writable, and 
executable to root and your user:

```
sudo chmod 770 cleanup_gentoo.sh
```

> - Now you launch the script like so:

```
sudo bash cleanup_gentoo.sh
```
----------

As an extra, here is how you can add the script to be globally runnable. This is super convenient 
since you can merely type something such as the following and have the script run:

sudo cleanup

Here's how we can do this:

```
// Syntax of doing so:

sudo ln <script location/script name> /usr/local/bin/<name you want to type to launch the script>

// More real example:

sudo ln /home/<user>/cleanup_gentoo.sh /usr/local/bin/cleanup

Whichever name you choose, just make sure it does not conflict with the name of an existing command.
```
