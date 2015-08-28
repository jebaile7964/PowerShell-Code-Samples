# Software Configuration Management Samples

#### [Push-DesktopPackages](https://github.com/jebaile7964/PowerShell-Code-Samples/blob/master/SCM/Push-DesktopPackages.ps1)

This script demonstrates how simple chocolatey package management is when trying to install a package on multiple servers.
while the code is not very hard to master, it eliminates hours of wasted time manually provisioning each server.  The
script can also be written into a workflow to install each package in parallel.

#### [Create-CloudRDPIcons](https://github.com/jebaile7964/PowerShell-Code-Samples/blob/master/SCM/CloudIconCreation/create-cloudrdpIcons.ps1)

This script automates the creation of RDP files with a couple of gui elements and a bit of regex. It accepts csv input requests other data via the gui elements. After all the data is gathered, the regex operations start and a for loop iterates through the csv data, creating folders and icons for each new user.

#### [Create-ShortcutIcons](https://github.com/jebaile7964/PowerShell-Code-Samples/blob/master/SCM/Create-ShortcutIcons.ps1)

Creates desktop shortcuts to a networked drive shared application. Written as a CMDlet. Can take multiple parameter sets, for user input and CSV input.

#### [Set-LegacyConsoleConfiguration](https://github.com/jebaile7964/PowerShell-Code-Samples/blob/master/SCM/Set-LegacyConsoleConfiguration.ps1)

Shortly after Windows 10's launch, a stream of customer calls required the creation of an easily run script that would make some changes to the way Windows 10 handled 16 bit code.  This script rolls back the command shell to legacy mode, and automatically installs the NTVDM optional feature, then prompts the user to reboot the computer.

#### [SSS Deployment Module](https://github.com/jebaile7964/PowerShell-Code-Samples/blob/master/SCM/SssDeployment.psm1)

Provides a list of tools for deployment of Propane Software:

##### Install-SSSChocolatey

ensures the proper execution policy and Installs Chocolatey.  Returns a value from Get-SssDeployDependencies

##### Install-SSSGit

Checks for and installs Chocolatey, then installs git through the Chocolatey service.  Returns a value from Get-SssDeployDependencies

##### Install-SssPowershell

Checks the version of PowerShell, and through the Chocolatey service, installs the latest version depending on the OS version.

##### Install-SssDotNet

Checks the version of the dot net framework, and installs it via the Chocolatey service.

##### Install-SssReportViewer

##### Install-SssClrTypes

##### Install-SssBaby36

Brings up the installation program and readies information for quick installation.  The Installation program is gui based and can't be run silently.

##### Install-SssOpenOffice

Installs OpenOffice through the Chocolatey Service.

##### Install-SssAdobeReader

##### Install-Mappoint

Installs Microsoft Mappoint from a provided network share folder.

##### Import-SssModules

Downloads Modules based on Validated set parameter provided, and copies them to a folder.

##### Set-SssPsProfileInfo

Sets the PS Profile for the logged in user.

##### Initialize-SssPathType

Creates a type from inline C# code that aids in the viewing and instantiation of custom objects.

##### Initialize-SssProgramType

Creates a type from inline C# code that aids in the viewing and instantiating of custom objects.

##### Set-SssModuleManifest

Creates manifest information, including versioning, of the module provided via parameter.

##### Get-SssDeployDependencies

Returns a value of all installed dependendcies on the computer.

##### Get-SssChocoInfo

Returns information regarding the Chocolatey Installation on the computer.

##### Get-SssInstalledProgramsInfo

Returns a value regarding all installed programs on Windows.

##### Get-SssPathInfo

Returns a value of all Paths related to the installation and deployment of Propane.

##### Get-SssPsProfileInfo

Checks to see if the proper values are set in the PS Profile of the logged on user.

##### Get-SssModule

Gets a list of all Suburban modules installed on the current machine.


