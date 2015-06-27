# Chocolatey Packages

Chocolatey is a Package Management utility, kind of like Apt-Get or Yum, but for Windows.  Here's some more information:

https://github.com/chocolatey/choco/wiki

The above files are packages for common software used in production that I have created.  They currently are used in a private 
repository as part of an automated provisioning process.  In order to view the packages, please download the NuGet Package 
Explorer at:

https://npe.codeplex.com/

One you've opened a package, you'll see that there is a 'Chocolatey Install' script that automates flow control, error handling,
downloading, and installation of the particular software package being handled.  On the left hand pane, you'll see relevant
information regarding the software package.  This information is populated via the Nuspec XML document supplied during
package creation.

Chocolatey packages are created using the NuSpec specification.  The package attributes are defined in an XML document, and the
installation script is created using Chocolatey parameters:

####NuSpec Reference:
http://docs.nuget.org/create/nuspec-reference
####Chocolatey Package Functions:
https://github.com/chocolatey/choco/wiki/HelpersReference

Chocolatey handles the creation of the packages, as long as you can supply the properties for the package installation.

This package management standard is followed by other package managers like Apt-Get, Yum, Ruby Gems, and others.
