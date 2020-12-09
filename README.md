# Project Mendacius

GUI based virtualization tool to run Linux, based on the Virtualization framework introduced by Apple for macOS Big Sur with support for Apple Silicon architecture (also supported by Intel based macs)

##Requirements (only for disk creation):
1. Homebrew (to install qemu-img) | use the command to install : /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" 
2. qemu-img : brew install qemu-img

##Building:
Decompress the SwiftTerm.zip file present in the Xcode project folder before building from source

Disk creation under Rosetta translation layer hasn't been verified.
Disk creation support for Apple Silicon based macs being worked upon.
