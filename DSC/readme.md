# Sample DSC Configuration for a DNS/DHCP Server

This script is a DSC push configuration script that installs the DNS and DHCP server roles on
a 2012 R2 server.  It was tested using Server 2012 R2 Core Datacenter Edition running PoSh v4.
The server was not joined to a domain.  The test server and configuration workstation have two
network interfaces, one called "TestInt."

Before testing this push configuration, please run the following on the test server:
```
    winrm qc
    winrm s winrm/config/client '@{TrustedHosts="*"}'
```

Also be sure to download the DSC Resource kit at:

    `https://github.com/PowerShell/xPSDesiredStateConfiguration`

and install it at ` $env:programfiles\windowspowershell\modules.`

Also, be sure to have KB2883200 installed.

DNS Record entries are created using Round Robin rotation.

#### Network Config:
```
Network ID: 192.168.0.0
Broadcast:  192.168.0.15
Gateway:    192.168.0.1
SubMask:    28
DNS Config: 192.168.0.2
Zone Name:  internal.contoso.org
Web Pool A Record: webpool1
```
#### Host Network Infrastructure Info
```
  Host Name    IP Address     Role         MAC Address
------------------------------------------------------------
  TestNode     192.168.0.2   DNS/DHCP    07-3D-D3-29-39-32
  Web1         192.168.0.3   Web Server  FF-CA-2D-36-B6-4A
  Web2         192.168.0.4   "           5A-62-17-7D-87-FA
  Web3         192.168.0.5   "           AE-6B-C3-DE-39-1B
  SQL1         192.168.0.6   DB          59-72-C2-C4-76-79
  Cache1       192.168.0.7   Cache       A2-A1-AC-4D-06-8F
```

In the configuration there are multiple components.  The first section sets variables.  There were only a few variables set,
but other configurations are static.  It's recommended for these configurations to be variables.

The next configuration imports the relevant DSC modules and sets the Ip Address configurations of the target node.  After
IP settings are configured, The features are then installed.  Once the features are installed, the roles are then configured.

DHCP is configured first.  Scope and scope options are set.  Next, lease reservations are configured.

DNS is configured next.  Since there is not a DNS server configuration resource, the 'Script' resource is used, which is
a resource that mimics resource creation.  It has three interfaces:  
```
SetScript 
TestScript 
GetScript
```

In the SetScript block, the actual script is laid out.  It creates primary zones, forwarders, and ensures that roundrobin is
set to true for the zone.  Next, the A records are created for three web servers, a SQL server, and a cache server.

The TestScript block runs a check to ensure that the settings configured in the SetScript block persist.  The GetScript
block allows DSC CMDlets like `Test-DSCConfiguration pipe a hash table back to the user to show what the exact settings
are on the node, and whether they are compliant.

The last section of the script fires up the Configuration and pushes the config up to the target node.
