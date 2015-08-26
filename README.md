# Powershell Code Samples

#### Samples Available:

## Active Directory

#### Get-UsersNotLoggedIn

A small script that utilizes the `Import-PSSession` CMDlet to import the ActiveDirectory module into a terminal server
to see what users from a particular OU haven't logged in.

#### Site DNS Tools Module

Provides a number of tools for reporting and maintenance of Site DNS settings.

## Chocolatey Packages

Samples of a couple of packages created that demonstrate how NuSpec requirements work with NuGet packages.  Instructions
are available [here](https://github.com/jebaile7964/PowerShell-Code-Samples/tree/master/Chocolatey%20Packages).

## Desired State Configuration

#### SamplePushConfig

Configures a server with the DNS and DHCP roles, then configures the roles to handle a web farm with 3 web servers, a sql
server, and a caching server.  More information [here](https://github.com/jebaile7964/PowerShell-Code-Samples/tree/master/DSC).

## Python Samples

#### WikiScrape

Uses MWClient to access the MediaWiki API.  It grabs all pages in the 'World of Warcraft' category, and parses it to a list page created in the MediaWiki user's page.  Requires the use of Python 2.7.9.  Sample of what the page looks like can be
found [here](https://en.wikipedia.org/wiki/User:Jebaile7964/World_of_Warcraft)

## Reporting

#### GDI Handle Logger

A script that helped to diagnose a printing issue that was happening on production TS servers.  Issue was resolved after
confirming that the spooler was crashing from a GDI handle overload.

## Software Configuration Management

#### Push-DesktopPackages

Utilizes `New-PSSession` and `Invoke-Command` CMDlets to install Adobe Reader and OpenOffice through the Chocolatey package
manager.  While done in a for loop in this sample, the same process can be done in parallel with a workflow.

#### Create-CloudRDPIcons

Uses .NET classes to create gui elements for use as a tool for junior resources.  It accepts input from a CSV, and some
User input.  After processing, it creates the icons in their respective folders for deployment.

#### Create-ShortcutIcons

Creates desktop shortcuts to a networked drive shared application.  Written as a CMDlet.  Can take multiple parameter sets,
for user input and CSV input.

#### Set-LegacyConsoleConfiguration

Makes a couple of modifications to the behavior of the CMD shell.  Brings back legacy mode, and installs NTVDM.exe.

#### SSS Deployment Module

Provides a set of tools that aid in the automated deployment of Software.

#### SQL

##### InstallSql2012

Installs and configures SQL Server 2012 Express silently.

#### Samples to be added:

##DSC
```
Chef Server Configuration
Web Server configuration
VM host configuration
SQL server config
WDS, WSUS configs
```

##Hyper-V
```
create virtual machines and install via lite-touch installation
create pull server, app server, sql server, chefserver, workstation
create hyper-v networking gw script
```
##SQL
Create sql connection to propane

##SCM
Deploy and automate configuration of propane

##AD
```
Create OU, users, and groups
create GPO and link it to an OU
promote domain controller
```

##TFS

##Chef
```
configure dsc pull server
configure linux web server
configure mysql server
configure x86 rdp server
Make sure to demonstrate how to make an LWRP
Install propane
```
