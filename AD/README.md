# Active Directory Script Samples

#### [Get-UsersNotLoggedIn](https://github.com/jebaile7964/PowerShell-Code-Samples/blob/master/AD/Get-UsersNotLoggedIn.ps1)

Gets a list of all users in a specific OU that have never logged in to a terminal server.  It's done first by importing
a PSsession from a domain controller to the terminal server in question, and then any users who have never logged in to
the server are displayed as output.

This is useful for licensing, especially in a tenanted server environment.

#### [Site DNS Tools Module](https://github.com/jebaile7964/PowerShell-Code-Samples/blob/master/AD/SiteDnsTools.psm1)

This module provides a number of tools useful for reporting and configuration of production servers across multiple sites:

##### Get-SSSRdpServersInfo

Pulls a listing of all productions servers by name, and includes IP, DNS, VPN Adapter, Site, and error info.

##### Get-SSSCloudSitesInfo

Pulls a list of all sites and includes their DC Name, DNS IP, Subnet, and Replication status.

##### Set-SSSSiteDnsClientConfiguration

checks servers for proper dns client settings and automatically sets them to the standard settings if they aren't compliant.

#### [New Customer Cloud Configuration Module](https://github.com/jebaile7964/PowerShell-Code-Samples/blob/master/AD/SssCloudCustomerConfiguration.psm1)

Provides a set of tools to automate the process of configuring the OU, groups, and users of a new VPS tenant.

##### New-SssRdpOuConfig

Creates a new OU and configures the container to specification.

##### New-SssCompanySecurityGroups

Creates security groups for the OU and configures them to specification.

##### Get-SssRdpGroupInfo

Pulls available Active Directory data for all groups belonging to VPS tenants.

##### Get-SssOuRdpInfo

Pulls available Active Directory data for all OU's belonging to VPS tenants.

##### New-SssRdpUser

Creates a new user for a particular VPS tenant and moves the user to their respective OU.  Also joins them to the group.

##### New-SssCloudCustomerConfiguration

Automates the task of New Cloud Customer configurations with the use of CSV file input.

##### Set-SssOuDescription

Bulk adds OU specific information regarding VPS Tenant infrastructure.
