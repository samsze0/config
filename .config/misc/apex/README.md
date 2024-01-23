# RawAccel

- Create two symbolic links inside `~/Saved Games/Respawn/Apex/local/` that points to `settings.cfg` and `videoconfig.txt`
- Create a symbolic link inside `~/Saved Games/Respawn/Apex/profile/` that points to `profile.cfg`

```shell
# Required installation of ln and sudo from scoop's main

cd "~/Saved Games/Respawn/Apex/local/"

rm settings.cfg videoconfig.txt

sudo ln -s ~/.config/misc/apex/settings.cfg<tab> settings.cfg
sudo ln -s ~/.config/misc/apex/videoconfig.txt<tab> videoconfig.txt

cd "~/Saved Games/Respawn/Apex/profile/"

rm profile.cfg

sudo ln -s ~/.config/misc/apex/profile.cfg<tab> profile.cfg
```