# Blender

```powershell
# Required installation of ln and sudo from scoop's main

cd "~/AppData/Roaming/Blender Foundation/Blender/4.0/config"

If (Test-Path userpref.blend) {
    rm userpref.blend
}

sudo ln -s ~/.config/misc/blender/config/userpref.blend<tab> userpref.blend

cd "~/AppData/Roaming/Blender Foundation/Blender/4.0"

If (Test-Path scripts) {
    rm -r -fo scripts
}

sudo ln -s ~/.config/misc/blender/scripts<tab> scripts
```