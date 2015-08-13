# Software Configuration Management Samples

#### Push-DesktopPackages

This script demonstrates how simple chocolatey package management is when trying to install a package on multiple servers.
while the code is not very hard to master, it eliminates hours of wasted time manually provisioning each server.  The
script can also be written into a workflow to install each package in parallel.

#### Create-CloudRDPIcons

This script automates the creation of RDP files with a couple of gui elements and a bit of regex. It accepts csv input requests other data via the gui elements. After all the data is gathered, the regex operations start and a for loop iterates through the csv data, creating folders and icons for each new user.

#### Create-ShortcutIcons

Creates desktop shortcuts to a networked drive shared application. Written as a CMDlet. Can take multiple parameter sets, for user input and CSV input.

#### Set-LegacyConsoleConfiguration

Shortly after Windows 10's launch, a stream of customer calls required the creation of an easily run script that would make some changes to the way Windows 10 handled 16 bit code.  This script rolls back the command shell to legacy mode, and automatically installs the NTVDM optional feature, then prompts the user to reboot the computer.
