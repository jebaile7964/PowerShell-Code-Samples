<#
Sample DSC Configuration for a DNS/DHCP Server
DNS is configured to house addresses for a server pool and a sql server
DHCP is configured for reservations to the server pool
Script was tested in a DSC push configuration.
Tested using Server 2012 R2 DC Core running PowerShell v4.
Server is not joined to a domain.
Test Server has two virtual network interfaces with one configured as "TestInt".
Before testing, please run the following on the test server:
    winrm qc
    winrm s winrm/config/client '@{TrustedHosts="*"}'
Also be sure to download the DSC Resource kit at:
    https://github.com/PowerShell/xPSDesiredStateConfiguration
and install it at $env:programfiles\windowspowershell\modules.
Also, be sure to have KB2883200 installed.
DNS Record entries are created using Round Robin rotation.
Network Config:
Network ID: 192.168.0.0
Broadcast:  192.168.0.15
Gateway:    192.168.0.1
SubMask:    28
DNS Config:
Zone Name:         internal.contoso.org
Web Pool A Record: webpool1
  Host Name    IP Address     Role         MAC Address
------------------------------------------------------------
  TestNode     192.168.0.2   DNS/DHCP    07-3D-D3-29-39-32
  Web1         192.168.0.3   Web Server  FF-CA-2D-36-B6-4A
  Web2         192.168.0.4   "           5A-62-17-7D-87-FA
  Web3         192.168.0.5   "           AE-6B-C3-DE-39-1B
  SQL1         192.168.0.6   DB          59-72-C2-C4-76-79
  Cache1       192.168.0.7   Cache       A2-A1-AC-4D-06-8F
#>

$serverip = "192.168.0.2"
$machinename = "TestNode"
$scopeid = "192.168.0.0"

Configuration TestNodeConfig{
    Param(
        $Machinename,
        $ServerIP,
        $ScopeID
    )

    Import-DscResource -Module xNetworking
    Import-DscResource -Module xDHCPServer

    node ($Machinename){
        LocalConfigurationManager{
            RebootNodeIfNeeded = $true
        }

        xIPAddress ServerIP
        {
            IPAddress = $ServerIP
            InterfaceAlias = "TestInt"
            DefaultGateway = "192.168.0.1"
            SubnetMask = 28
            AddressFamily = "IPv4"
        }
        xDNSServerAddress ServerDNS 
        {
            Address = $ServerIP
            InterfaceAlias = "Ethernet"
            AddressFamily = "IPv4"
        }
        WindowsFeature DHCP
        {
           Ensure = "Present"
           Name = "DHCP"
           DependsOn = "[xIPAddress]ServerIP","[xDNSServerAddress]ServerDNS"
        }
        WindowsFeature DNS
        {
           Ensure = "Present"
           Name = "DNS"
           DependsOn = "[xIPAddress]ServerIP","[xDNSServerAddress]ServerDNS"
        }
        xDhcpServerScope ServerScope
        {
            IPStartRange = "192.168.0.3"
            IPEndRange = "192.168.0.7"
            Name = "TestScope1"
            SubnetMask = "255.255.255.240"
            State = "Active"            
            Ensure = "Present"
            LeaseDuration = "7:00:00"
            DependsOn = "[WindowsFeature]DHCP"
            
        }
        xDhcpServerOption ServerOpt
        {
            ScopeID = $ScopeID
            DnsServerIPAddress = $ServerIP
            DnsDomain = "TestDomain"
            AddressFamily = "IPv4"            
            Ensure = "Present"
            DependsOn = "[xDhcpServerScope]ServerScope"
        }
        xDhcpServerReservation Web1Res
        {
            ScopeID = $ScopeID
            IPAddress = "192.168.0.3"
            ClientMACAddress = "FF-CA-2D-36-B6-4A"
            Name = "Web1"
            AddressFamily = "IPv4" 
            Ensure = "Present"
            DependsOn = "[xDhcpServerScope]ServerScope"  
        }
        xDhcpServerReservation Web2Res
        {
            ScopeID = $ScopeID
            IPAddress = "192.168.0.4"
            ClientMACAddress = "5A-62-17-7D-87-FA"
            Name = "Web2"
            AddressFamily = "IPv4" 
            Ensure = "Present"
            DependsOn = "[xDhcpServerScope]ServerScope"  
        }
        xDhcpServerReservation Web3Res
        {
            ScopeID = $ScopeID
            IPAddress = "192.168.0.5"
            ClientMACAddress = "AE-6B-C3-DE-39-1B"
            Name = "Web3"
            AddressFamily = "IPv4" 
            Ensure = "Present"
            DependsOn = "[xDhcpServerScope]ServerScope" 
        }
        xDhcpServerReservation SQL1Res
        {
            ScopeID = $ScopeID
            IPAddress = "192.168.0.6"
            ClientMACAddress = "59-72-C2-C4-76-79"
            Name = "SQL1"
            AddressFamily = "IPv4" 
            Ensure = "Present"
            DependsOn = "[xDhcpServerScope]ServerScope"  
        }
        xDhcpServerReservation Cache1Res
        {
            ScopeID = $ScopeID
            IPAddress = "192.168.0.7"
            ClientMACAddress = "A2-A1-AC-4D-06-8F"
            Name = "Cache1"
            AddressFamily = "IPv4"
            Ensure = "Present" 
            DependsOn = "[xDhcpServerScope]ServerScope"  
        }
        Script DNSConfig{
            SetScript = {
                          Add-DnsServerPrimaryZone -Name "internal.contoso.org" -ZoneFile "internal.contoso.org.dns"
                          Add-DnsServerPrimaryZone -NetworkID 192.168.0.0/28 -ZoneFile "0.168.192.in-addr.arpa.dns"

                          Add-DnsServerForwarder -IPAddress 8.8.8.8 -PassThru
                          Add-DnsServerForwarder -IPAddress 4.2.2.2 –PassThru

                          dnscmd.exe localhost /config /roundrobin 1

                          Add-DnsServerResourceRecordA -Name "WebPool1" -ZoneName "Internal.contoso.org" `
			                  -ipaddress 192.168.0.3,192.168.0.4,192.168.0.5
                          Add-DnsServerResourceRecordA -Name "sql1" -ZoneName "Internal.contoso.org" `
			                  -ipaddress 192.168.0.6
                          Add-DnsServerResourceRecordA -Name "cache1" -ZoneName "Internal.contoso.org" `
			                  -ipaddress 192.168.0.7

                          Add-DnsServerResourceRecord -name "3" -Ptr -ZoneName "0.0.168.192.in-addr.arpa" `
                              -PtrDomainName "webpool1.internal.contoso.org"
                          Add-DnsServerResourceRecord -name "4" -Ptr -ZoneName "0.0.168.192.in-addr.arpa" `
                              -PtrDomainName "webpool1.internal.contoso.org"
                          Add-DnsServerResourceRecord -name "5" -Ptr -ZoneName "0.0.168.192.in-addr.arpa" `
                              -PtrDomainName "webpool1.internal.contoso.org"
                          Add-DnsServerResourceRecord -name "6" -Ptr -ZoneName "0.0.168.192.in-addr.arpa" `
                              -PtrDomainName "sql1.internal.contoso.org"
                          Add-DnsServerResourceRecord -name "7" -Ptr -ZoneName "0.0.168.192.in-addr.arpa" `
                              -PtrDomainName "cache1.internal.contoso.org"
                         }
            TestScript = { if((get-dnsserverzone).zonename -ccontains "0.0.168.192.in-addr.arpa" -and "internal.contoso.org") `
			                   {return (Get-DnsServerResourceRecord -zoneName "internal.contoso.org" -name "webpool1" `
                                    | select-object -expandproperty recorddata).ipv4address.ipaddresstostring -ccontains `
                                    "192.168.0.3" -and "192.168.0.4" -and "192.168.0.5"}
                           else{
                             return $false
                           }
                         }
            GetScript = { return @{ DNSZone = ((get-dnsserverzone).zonename | where-object {$_ -eq "internal.contoso.org"})
			 	                    ARPZone = ((get-dnsserverzone).zonename | where-object {$_ -eq "0.0.168.192.in-addr.arpa"})
				                     Web1ARec = ((get-dnsserverresourcerecord -zonename "internal.contoso.org" -name "webpool1" `
						                         | select-object -expandproperty recorddata).ipv4address.ipaddresstostring | `
						                         where-object {$_ -eq "192.168.0.3"})
				                     Web2ARec = ((get-dnsserverresourcerecord -zonename "internal.contoso.org" -name "webpool1" `
						                         | select-object -expandproperty recorddata).ipv4address.ipaddresstostring | `
						                          where-object {$_ -eq "192.168.0.4"})
				                     Web3ARec = ((get-dnsserverresourcerecord -zonename "internal.contoso.org" -name "webpool1" `
						                         | select-object -expandproperty recorddata).ipv4address.ipaddresstostring | `
						                          where-object {$_ -eq "192.168.0.5"})
				                     SQL1ARec = ((get-dnsserverresourcerecord -zonename "internal.contoso.org" -name "sql1" `
						                         | select-object -expandproperty recorddata).ipv4address.ipaddresstostring | `
						                         where-object {$_ -eq "192.168.0.6"})
				                     Cache1ARec = ((get-dnsserverresourcerecord -zonename "internal.contoso.org" -name "cache1" `
						                           | select-object -expandproperty recorddata).ipv4address.ipaddresstostring | `
						                           where-object {$_ -eq "192.168.0.7"})  
				                     RoundRobin = ((get-dnsserver | select-object -expandproperty serversettings).roundrobin)
				                     Fwdr1 = ((get-dnsserver | select-object -expandproperty serversettings).ipaddress.ipaddresstostring `
						                      | where-object {$_ -eq "8.8.8.8"})
				                     Fwdr2 = ((get-dnsserver | select-object -expandproperty serversettings).ipaddress.ipaddresstostring `
						                      | where-object {$_ -eq "4.2.2.2"})   
			                       }
                        }
            DependsOn = "[WindowsFeature]DNS"
        }
    }
}


Set-Location c:

# Push the DSC configuration to the Test server
TestNodeConfig -machinename "TestNode" -serverIP "192.168.0.2" -scopeid "192.168.0.0"

start-dscconfiguration -computername "TestNode" -path "c:\testnodeconfig"
