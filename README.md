Purpose
=====

The purpose of this script is to just be a simple script to run after uninstalling things to clean the
dependencies or wanting to clean portages left over tars from previous emerges. There's a couple extra 
handy things like emptying the trash and /var/tmp and /tmp too, just to be thorough

How to use
====
> - First we need to change the scripts permissions. This will make the script readable, writable, and 
executable to root and your user. 

```
sudo chmod 770 cleanup_gentoo.sh
```

> - Now you launch the script like so. 

```
sudo bash cleanup_gentoo.sh
```
----------

As an added bonus here is how you can add the script to be globally runnable. This is super convenient 
since you can merely type something such as the following and have the script run:

sudo cleanup-gentoo

Here's how we can do this:

```
// Syntax of doing so:

sudo ln <script location/script name> /usr/local/bin/<name you want to type to launch the script>

// More real example:

sudo ln /home/<user>/cleanup_gentoo.sh /usr/local/bin/cleanup-gentoo
```
