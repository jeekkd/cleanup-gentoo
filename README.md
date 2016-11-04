Purpose
=====

The purpose of this script is to just be a simple script to run after uninstalling packages to clean the
dependencies or wanting to clean portages leftovers from previous emerges. There is a couple extra 
handy things like emptying the trash, cleaning /var/tmp and /tmp, checks the system for compliance with
Gentoo Linux Security Advisories, empty browser cache, etc.

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
sudo bash cleanup_gentoo.sh
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

Additional Maintenance
====

Updating a system goes hand in hand with cleaning it. Having a good way to keep your system up to date is
ideal, personally I would recommend [Sakakis genup script](https://github.com/sakaki-/genup) from his [sakaki-tools overlay](https://github.com/sakaki-/sakaki-tools) 

So you could do the following:

```
git clone https://github.com/sakaki-/genup && cd genup
```

Then link the script into your /usr/local/bin/ like mentioned above. Or if you would like to run additional
command line parameters on the genup script you could put the following into a .sh file and use that instead

```
#!/usr/bin/env bash
genup --no-kernel-upgrade --dispatch-conf
```
