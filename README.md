# Dotfiles

**Homebrew**
- `brew install cmacrae/formulae/spacebar gnu-sed koekeishiya/formulae/yabai koekeishiya/formulae/skhd less tree wget curl fd fzf bat bottom node miniforge git ripgrep gnu-sed`
- `brew install visual-studio-code slack postman brave-browser warp homebrew/cask-versions/firefox-developer-edition karabiner-elements docker spotify --cask`

**Karabiner**
- Goto `karabiner/` and run `node config.js`

**Spacebar**
- Spacebar doesn't have apple silicon built
- Install rosetta beforehand with `softwareupdate --install-rosetta`

**Yabai**
- Disable SIP `csrutil disable` (in recovery mode)
- Enable arm64e (apple silicon) `sudo nvram boot-args=-arm64e_preview_abi` (then reboot)
- Load scripting addition `sudo yabai --load-sa`