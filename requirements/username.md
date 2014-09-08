# Username, Group and Environment

It is suggested that a separate user is created for the apps. In this example we create a user and a group for "harvest\_apps".

```bash
sudo useradd -d "/home/harvest_apps" -m -r -U "harvest_apps"
sudo passwd "harvest_apps"
```

Login using the created user.

```bash
su - "harvest_apps"
```

Also ensure that the "LANG" property is set to "\*.UTF-8" when you run "env" for the user account.

```bash
env
...
LANG=en_US.UTF-8
...
```

Harvest sends all data in UTF-8 format. If this is not set, it will cause problems. To change to UTF-8, execute the following.

```bash
sudo vi /etc/sysconfig/i18n
```

Change LANG as indicated below. The file might not exist, in which case just add the following line and save.

```bash
LANG="en_US.UTF-8"
```

Reboot your system.

```bash
sudo reboot
```

Once the machine is up and running, login with the account and re-perform the check.

```bash
su - "harvest_apps"
env
...
LANG=en_US.UTF-8
...
```

If your machine requires *SSH keys* to login, do not forget to copy the necessary keys in the *".ssh"* in the user directory.