# Active Directory Script Samples

#### Get-UsersNotLoggedIn

Gets a list of all users in a specific OU that have never logged in to a terminal server.  It's done first by importing
a PSsession from a domain controller to the terminal server in question, and then any users who have never logged in to
the server are displayed as output.

This is useful for licensing, especially in a tenanted server environment.

#### Site DNS Tools Module

This module provides a number of tools useful for reporting and configuration of production servers across multiple sites:

##### Get-SSSRdpServersInfo

Pulls a listing of all productions servers by name, and includes IP, DNS, VPN Adapter, Site, and error info.

##### Get-SSSCloudSitesInfo

Pulls a list of all sites and includes their DC Name, DNS IP, Subnet, and Replication status.

##### Set-SSSSiteDnsClientConfiguration

checks servers for proper dns client settings and automatically sets them to the standard settings if they aren't compliant.
