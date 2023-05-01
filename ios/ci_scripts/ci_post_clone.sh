#!/bin/sh

echo 'Running ci_post_clone.sh...'

# The default execution directory of this script is the ci_scripts directory.
echo 'Moving to clone repo'
cd $CI_WORKSPACE # change working directory to the root of your cloned repo.

# Install Flutter using git.
echo 'Installing flutter'
git clone https://github.com/flutter/flutter.git --depth 1 -b stable $HOME/flutter
export PATH="$PATH:$HOME/flutter/bin"

# Install Flutter artifacts for iOS (--ios), or macOS (--macos) platforms.
flutter precache --ios

# Install Flutter dependencies.
echo 'Running pub get'
flutter pub get

# Install CocoaPods using Homebrew.
echo 'Installing CocoaPods'
HOMEBREW_NO_AUTO_UPDATE=1 # disable homebrew's automatic updates.
brew install cocoapods

# Install CocoaPods dependencies.
echo 'Moving to ios folder and running pod'
cd ios && pod install # run `pod install` in the `ios` directory.

echo 'ci_post_clone.sh is completed'
exit 0