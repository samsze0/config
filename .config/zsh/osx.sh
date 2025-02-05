#!/usr/bin/env bash

# Show notification using AppleScript
osx_notify() {
	osascript -e "display notification \"$2\" with title \"$1\""
}

osx_find_bundle_id() {
	osascript -e "id of app \"$1\""
}

osx_init_keymaps() {
	# Alternatively, directly edit the plist files
	# https://www.reddit.com/r/MacOS/comments/12s4i9k/question_is_there_a_way_to_configure/
	echo "Not ready"
	exit 1
	osascript ~/.config/apple/keymaps.scpt
}

osx_global_settings() {
	defaults read ~/Library/Preferences/.GlobalPreferences.plist
}

osx_finder_settings() {
	defaults read ~/Library/Preferences/com.apple.finder.plist
}

osx_plist_to_xml() {
	cp "$1" "$1.xml"
	plutil -convert xml1 "$1.xml"
}

osx_init() {
	# https://macos-defaults.com/
	# https://sxyz.blog/macos-setup/

	# Auto hide the menubar
	defaults write -g _HIHideMenuBar -bool true

  # Decrease spacing of the menu bar icons (to avoid them being hidden by top notch)
  defaults write -g NSStatusItemSpacing -int 10

	# HIToolbox: Set function key usage to "Show Emoji & Symbols"
	defaults write com.apple.HIToolbox AppleFnUsageType -int "2"

	# Enable full keyboard access for all controls
	defaults write -g AppleKeyboardUIMode -int 3

	# Enable press-and-hold repeating
	defaults write -g ApplePressAndHoldEnabled -bool false

	# Key repeat delay and rate
	defaults write -g InitialKeyRepeat -int 13 # by default minimum is 15 (225 ms)
	defaults write -g KeyRepeat -float 1.7     # by default minimum is 2 (30 ms)

	# Enable "Natural" scrolling
	defaults write -g com.apple.swipescrolldirection -bool true

	# Disable smart dash/period/quote substitutions
	defaults write -g NSAutomaticDashSubstitutionEnabled -bool false
	defaults write -g NSAutomaticPeriodSubstitutionEnabled -bool false
	defaults write -g NSAutomaticQuoteSubstitutionEnabled -bool false

	# Disable automatic capitalization
	defaults write -g NSAutomaticCapitalizationEnabled -bool false

	# Using expanded "save panel" by default
	defaults write -g NSNavPanelExpandedStateForSaveMode -bool true
	defaults write -g NSNavPanelExpandedStateForSaveMode2 -bool true

	# Increase window resize speed for Cocoa applications
	defaults write -g NSWindowResizeTime -float 0.001

	# Save to disk (not to iCloud) by default
	defaults write -g NSDocumentSaveNewDocumentsToCloud -bool true

	# Jump to the spot that's clicked on the scroll bar
	defaults write -g AppleScrollerPagingBehavior -bool true

	# Prefer tabs when opening documents
	defaults write -g AppleWindowTabbingMode -string always

	# Dock: Set icon size and dock orientation
	defaults write com.apple.dock tilesize -int 48
	defaults write com.apple.dock orientation -string left

	# Dock: Set dock to auto-hide, and transparentize icons of hidden apps (⌘H)
	defaults write com.apple.dock autohide -bool true
	defaults write com.apple.dock showhidden -bool true

	# Dock: Disable to show recents, and light-dot of running apps
	defaults write com.apple.dock show-recents -bool false
	defaults write com.apple.dock show-process-indicators -bool false

	# Dock: Unpin all apps from dock (Or use dockutil)
	defaults write com.apple.dock persistent-apps -array ""

	# Dock: Disable rearrange automatically
	defaults write com.apple.dock "mru-spaces" -bool false

	# Dock: Disable group apps by window automatically
	defaults write com.apple.dock "expose-group-apps" -bool false

	# Dock: Display have separate spaces (required by yabai)
	defaults write com.apple.spaces "spans-displays" -bool false

	# Finder: Allow quitting via ⌘Q
	defaults write com.apple.finder QuitMenuItem -bool true

	# Finder: Disable warning when changing a file extension
	defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

	# Finder: Show all files and their extensions
	defaults write com.apple.finder AppleShowAllExtensions -bool true
	defaults write com.apple.finder AppleShowAllFiles -bool true

	# Finder: Show path bar, and layout as multi-column
	defaults write com.apple.finder ShowPathbar -bool true
	defaults write com.apple.finder FXPreferredViewStyle -string clmv

	# Finder: Search in current folder by default
	defaults write com.apple.finder FXDefaultSearchScope -string SCcf

	# Finder: Keep the desktop clean
	defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false
	defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool false
	defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool false
	defaults write com.apple.finder ShowMountedServersOnDesktop -bool false

	# Finder: Show directories first
	defaults write com.apple.finder _FXSortFoldersFirst -bool true

	#Finder:  New window use the $HOME path
	defaults write com.apple.finder NewWindowTarget -string PfHm
	defaults write com.apple.finder NewWindowTargetPath -string "file://$HOME/"

	# Finder: Allow text selection in Quick Look
	defaults write com.apple.finder QLEnableTextSelection -bool true

	# Finder: Show metadata info, but not preview in info panel
	defaults write com.apple.finder FXInfoPanesExpanded -dict MetaData -bool true Preview -bool false

	# Disk images: Disable disk image verification
	defaults write com.apple.frameworks.diskimages skip-verify -bool true
	defaults write com.apple.frameworks.diskimages skip-verify-locked -bool true
	defaults write com.apple.frameworks.diskimages skip-verify-remote -bool true

	# Crash reporter: Disable crash reporter
	defaults write com.apple.CrashReporter DialogType -string none

	# Trackpad: Enable trackpad tap to click
	defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
	defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true

	# Trackpad: Enable drag lock
	defaults write com.apple.AppleMultitouchTrackpad "DragLock" -bool true

	# Trackpad: Enable 3-finger drag
	defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true
	defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool true

	# Activity Monitor: Sort by CPU usage
	defaults write com.apple.ActivityMonitor SortColumn -string CPUUsage
	defaults write com.apple.ActivityMonitor SortDirection -int 0

	# Launch Services: Disable quarantine for downloaded apps
	defaults write com.apple.LaunchServices LSQuarantine -bool false

	# Screen capture: Set the filename which screencaptures should be written
	defaults write com.apple.screencapture include-date -bool false

	# Screen capture: Display the thumbnail after taking a screenshot
	defaults write com.apple.screencapture show-thumbnail -bool true

	# AdLib: Disable personalized advertising
	defaults write com.apple.AdLib forceLimitAdTracking -bool true
	defaults write com.apple.AdLib allowApplePersonalizedAdvertising -bool false
	defaults write com.apple.AdLib allowIdentifierForAdvertising -bool false

  # AeroSpace: Workaround for the small window size in mission control issue
  # https://nikitabobko.github.io/AeroSpace/guide#a-note-on-mission-control
  defaults write com.apple.dock expose-group-apps -bool true

	# Reload Dock
	killall Dock

	# Reload SystemUIServer
	killall SystemUIServer

	# Reload Finder
	killall Finder
}
