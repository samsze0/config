# Apex

```powershell
# Required installation of ln and sudo from scoop's main

cd "~/Saved Games/Respawn/Apex/local/"

rm settings.cfg videoconfig.txt

sudo ln -s ~/.config/misc/apex/settings.cfg<tab> settings.cfg
sudo ln -s ~/.config/misc/apex/videoconfig.txt<tab> videoconfig.txt

cd "~/Saved Games/Respawn/Apex/profile/"

rm profile.cfg

sudo ln -s ~/.config/misc/apex/profile.cfg<tab> profile.cfg
```

Note: `userpref.blend` is not complatible between macOS and Windows