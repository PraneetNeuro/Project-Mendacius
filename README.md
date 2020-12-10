# Project Mendacius

GUI based virtualization tool to run Linux, based on the Virtualization framework introduced by Apple for macOS Big Sur with support for Apple Silicon architecture (also supported by Intel based macs)

Makes the experience much more simpler by having quick action buttons for installing openssh-server in the guest operating system and one for IP address lookup making it one step easier to launch applications in GUI mode through ssh and XQuartz

## Requirements (only for disk creation):
1. Homebrew (to install qemu-img)
2. qemu-img

## Building:
Decompress the SwiftTerm.zip file present in the Xcode project folder before building from source

## Note:
Disk creation under Rosetta translation layer hasn't been verified.
Disk creation support for Apple Silicon based macs being worked upon.
