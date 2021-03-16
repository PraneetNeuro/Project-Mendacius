# Project Mendacius

GUI based virtualization tool to run Linux, based on the Virtualization framework introduced by Apple for macOS Big Sur with support for Apple Silicon architecture (also supported by Intel based macs)

Makes the experience much more simpler by having quick action buttons for installing openssh-server in the guest operating system and one for IP address lookup making it one step easier to launch applications in GUI mode through ssh and XQuartz

## Requirements:
1. Homebrew (to install qemu)
2. qemu (For running GUI based operating systems)

## Building:
## Xcode is requirement for building the source.
Decompress the SwiftTerm.zip file present in the Xcode project folder before building from source. 

## Note:
Disk creation under Rosetta translation layer hasn't been verified.
Disk creation support for Apple Silicon based macs being worked upon.

## Personalisation:
Customise the console's foreground color by using the command "defaults write com.luby.Project-Mendacius vmfg_<r/g/b> <value in range 0-65535>"

Customise the console's background color by using the command "defaults write com.luby.Project-Mendacius vmbg_<r/g/b> <value in range 0-65535>"

## Screenshots:
![Homescreen](https://github.com/PraneetNeuro/Project-Mendacius/blob/main/snaps/home.png?raw=true)
![Download the required images to run Ubuntu-Server based on CPU architecture](https://github.com/PraneetNeuro/Project-Mendacius/blob/main/snaps/downloads.png?raw=true)
![Create / Configure new VM](https://github.com/PraneetNeuro/Project-Mendacius/blob/main/snaps/create-new-vm.png?raw=true)
![VM Configuration](https://github.com/PraneetNeuro/Project-Mendacius/blob/main/snaps/configure.png?raw=true)
![VM running Ubuntu](https://github.com/PraneetNeuro/Project-Mendacius/blob/main/snaps/vm_ubuntu.png?raw=true)
