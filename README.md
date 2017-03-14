Purpose
=====

Cleanup your Gentoo system, files accumulate in /usr/portage/distfiles, /usr/portage/packages, browser caches
add up, use the /boot, kernel sources, kernel module, cleaning menus to reclaim space from used kernels and
sources.

There is extra handy things like emptying the trash, cleaning /var/tmp and /tmp, checks the system for compliance with
Gentoo Linux Security Advisories, removing packages with no parent or are obselete, etc.

How to use
====

- Lets get the source

```
git clone https://github.com/jeekkd/cleanup-gentoo.git && cd cleanup-gentoo
```

- First we must change the scripts permissions. This will make the script readable, writable, and 
executable to root and your user:

```
sudo chmod 770 cleanup_gentoo.sh
```

You can launch the script like so

```
sudo sh cleanup_gentoo.sh
```
----------

Additionally, here is how you can add the script to be globally runnable. This is super convenient 
since you can merely type something such as the following and have the script run:

```
sudo cleanup
```

Here's how we can do this:

```
# Syntax of doing so:

sudo ln <script location/script name> /usr/local/bin/<name you want to type to launch the script>

# Realistic example:

sudo ln /home/<user>/cleanup_gentoo.sh /usr/local/bin/cleanup

Whichever name you choose, just make sure it does not conflict with the name of an existing command.
```

