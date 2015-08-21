Function Set-SSSDnsSiteClientConfiguration {
    BEGIN{
        $AllSites = Get-SSSCloudSitesInfo
        $Site1 = $AllSites | Where-Object sitename -match $Site1
        $Site2 = $AllSites | Where-Object sitename -match $Site2
        $RDPServer = Get-SSSRDPServersInfo
        $DnsChangeSuccess = @()
        $DnsChangeFailure = @()
        $DnsSettingsSkip = @()
        $i = 0
    }
    PROCESS{
        foreach ($r in $RDPServer){
            $Site = $AllSites | Where-Object sitename -eq $r.site
            if ($r.sitequerysuccessful -eq $true -and $Site.sitename -ne $Site1.sitename){
                if ($r.primarydns -eq $site.dnsip -and $r.secondarydns -eq $site2.dnsip){
                    Write-Host -ForegroundColor Green "$($r.name) is properly configured and will be skipped."
                    $DnsSettingsSkip += $r
                }  
                else{
                    $ScriptBlock = { $SetAdapter = gwmi win32_networkadapterconfiguration | Where-Object ipaddress -match $using:r.ipv4address
                                     $DNSServers = "$($using:site.dnsip)","$($using:Site1.dnsip)"
                                     $ExitCode = $SetAdapter.SetDnsServerSearchOrder($DNSServers)
                                     $SessionObject = new-object -TypeName psobject
                                     $SessionObjectProperties = gwmi win32_networkadapterconfiguration | Where-Object ipaddress -match $using:r.ipv4address `
                                                                 | select description,ipaddress,dnsserversearchorder
                                     $SessionObject | Add-Member -MemberType NoteProperty -Name 'ServerName' -Value $using:r.name
                                     $SessionObject | Add-Member -MemberType NoteProperty -Name 'Description' -Value $SessionObjectProperties.description
                                     $SessionObject | Add-Member -MemberType NoteProperty -Name 'IpAddress' -Value $SessionObjectProperties.ipaddress
                                     $SessionObject | Add-Member -MemberType NoteProperty -Name 'DnsServerSearchOrder' `
                                        -Value $SessionObjectProperties.dnsserversearchorder
                                     $SessionObject | Add-Member -MemberType NoteProperty -Name 'ReturnValue' -Value $ExitCode.returnvalue
                                     Write-Output $SessionObject }
                    $Session = New-PSSession $r.name
                    $DnsSettingsChange = Invoke-Command -Session $Session -ScriptBlock $ScriptBlock
                }
            }
            elseif($r.sitequerysuccessful -eq $true -and $Site.sitename -eq $Site1.sitename){
                if ($r.primarydns -eq $site.dnsip -and $r.secondarydns -eq $Site2.dnsip){
                    Write-Host -ForegroundColor Green "$($r.name) is properly configured and will be skipped."
                }  
                else{
                    $ScriptBlock = { $SetAdapter = gwmi win32_networkadapterconfiguration | Where-Object ipaddress -match $using:r.ipv4address
                                     $DNSServers = "$($using:site.dnsip)","$($using:Site2.dnsip)"
                                     $ExitCode = $SetAdapter.SetDnsServerSearchOrder($DNSServers)
                                     $SessionObject = new-object -TypeName psobject
                                     $SessionObjectProperties = gwmi win32_networkadapterconfiguration | Where-Object ipaddress -match $using:r.ipv4address `
                                                                 | select description,ipaddress,dnsserversearchorder
                                     $SessionObject | Add-Member -MemberType NoteProperty -Name 'ServerName' -Value $using:r.name
                                     $SessionObject | Add-Member -MemberType NoteProperty -Name 'Description' -Value $SessionObjectProperties.description
                                     $SessionObject | Add-Member -MemberType NoteProperty -Name 'IpAddress' -Value $SessionObjectProperties.ipaddress
                                     $SessionObject | Add-Member -MemberType NoteProperty -Name 'DnsServerSearchOrder' `
                                        -Value $SessionObjectProperties.dnsserversearchorder
                                     $SessionObject | Add-Member -MemberType NoteProperty -Name 'ReturnValue' -Value $ExitCode.returnvalue
                                     Write-Output $SessionObject }
                    $Session = New-PSSession $r.name
                    $DnsSettingsChange = Invoke-Command -Session $Session -ScriptBlock $ScriptBlock
                    $Session | Remove-PSSession
                }         
            }
            elseif($r.sitequerysuccessful -eq $false){
                Write-host -ForegroundColor Yellow "$($r.name) does not have complete Site information and will be skipped."
            }
            if ($DnsSettingsChange.returnvalue -eq 0){
                $DnsChangeSuccess += $DnsSettingsChange
            }
            elseif ($DnsSettingsChange.returnvalue -ne 0 -and $DnsSettingsChange.returnvalue -ne $null){
                $DnsChangeFailure += $DnsSettingsChange
            }
            $i++
            Write-Progress -Activity 'Making DNS Modifications...' -Status "$i of $($RDPServer.count) Changes completed." -PercentComplete (($i/$RDPServer.count) * 100 )
        }
    }
    END{
        $Success = Write-Host -ForegroundColor Green 'Successful DNS Changes:'
        Write-Output $Success $DnsChangeSuccess
        $Failure = Write-Host -ForegroundColor Red 'Unsuccessful DNS Changes:'
        Write-Output $Failure $DnsChangeFailure
        $Skipped = Write-Host -ForegroundColor Green 'Skipped DNS Settings:'
        Write-Output $Skipped $DnsSettingsSkip
        Get-PSSession | Remove-PSSession
    }
}

Function Get-SSSRDPServersInfo{
    BEGIN{
        $i = 0
        $RDPVM = Get-ADComputer -Filter * -Properties * | Where-Object name -Match 'RDPVM'
        $RDPVMArray = @()
    }
    PROCESS{
        foreach ($r in $RDPVM){
            $RDPServerObject = New-Object -TypeName psobject
            $RDPServerObject | Add-Member -MemberType NoteProperty -Name 'Name' -Value $r.name
            $RDPServerObject | Add-Member -MemberType NoteProperty -Name 'IPv4Address' -Value $r.ipv4address
            $RDPServerSiteQuery = nltest /server:$($r.name) /dsgetsite | select -First 1
            if ($LASTEXITCODE -eq 0){
                $RDPServerObject | Add-Member -MemberType NoteProperty -Name 'Site' -Value $RDPServerSiteQuery
                $RDPServerObject | Add-Member -MemberType NoteProperty -Name 'SiteQuerySuccessful' -Value $true
                $Session = New-PSSession $r.name
                $ScriptBlock = { gwmi win32_networkadapterconfiguration | select description,ipaddress,dnsserversearchorder }
                $AdapterInfo = Invoke-Command -Session $Session -ScriptBlock $ScriptBlock
                $Session | Remove-PSSession
                $RdpServerObjectVpniInfo = $AdapterInfo | Where-Object description -match $VpnAdapter
                $RdpServerObjectAdapterInfo = $AdapterInfo | Where-Object ipaddress -match $r.ipv4address
                $RDPServerObject | add-member -MemberType NoteProperty -Name 'HamachiAddress' -Value $RdpServerObjectVpnInfo.ipaddress[0]
                $RDPServerObject | add-member -MemberType NoteProperty -Name 'PrimaryDns' -Value $RdpServerObjectAdapterInfo.dnsserversearchorder[0]
                $RDPServerObject | Add-Member -MemberType NoteProperty -Name 'SecondaryDns' -Value $RdpServerObjectAdapterInfo.dnsserversearchorder[1]
            }
            else {
                $RDPServerObject | Add-Member -MemberType NoteProperty -Name 'SiteQuerySuccessful' -Value $false
                $RDPServerObject | add-member -MemberType NoteProperty -Name 'VpnAddress' -Value $null
                $RDPServerObject | add-member -MemberType NoteProperty -Name 'PrimaryDns' -Value $null
                $RDPServerObject | Add-Member -MemberType NoteProperty -Name 'SecondaryDns' -Value $null
            }
            $RDPVMArray += $RDPServerObject
            $i++
            Write-Progress -Activity 'Gathering RDP Server information.  This will take about a minute...' -Status `
                "Completed $i of $($RDPVM.count) Queries" -PercentComplete (($i/$rdpvm.count) * 100)
        }
    }
    END{
        Get-PSSession | Remove-PSSession
        Write-Output $RDPVMArray
    }
}

Function Get-SSSCloudSitesInfo{
    BEGIN{
        $Sites = Get-ADReplicationSite -Filter * | select name,distinguishedname
        $SiteInfo = @()
        $i = 0
    }
    PROCESS{
        foreach ($s in $Sites){
            $SiteObject = New-Object -TypeName psobject
            $SiteObject | Add-Member -MemberType NoteProperty -Name 'SiteName' -Value $s.name
            $siteName = $($s.name)
            $configNCDN = (Get-ADRootDSE).ConfigurationNamingContext
            $siteContainerDN = ("CN=Sites," + $configNCDN)
            $serverContainerDN = "CN=Servers,CN=" + $siteName + "," + $siteContainerDN
            $DnsServer = Get-ADObject -SearchBase $serverContainerDN -SearchScope OneLevel -filter { objectClass -eq "Server" } -Properties "DNSHostName", "Description"
            $SiteObject | Add-Member -MemberType NoteProperty -Name 'DnsServer' -Value $DnsServer.name
            $DnsIp = Get-ADComputer -Filter {name -eq $dnsserver.name} -Properties ipv4address
            $SiteObject | Add-Member -MemberType NoteProperty -Name 'DnsIp' -Value $DnsIp.ipv4address
            $LastReplicationSuccess = Get-ADReplicationUpToDatenessVectorTable $DnsServer.name
            $SiteObject | Add-Member -MemberType NoteProperty -Name 'LastReplicationSuccess' -Value $LastReplicationSuccess.Lastreplicationsuccess
            $Subnets = Get-ADReplicationSubnet -Filter * -Properties * | Where-Object site -eq $s.distinguishedname
            $SiteObject | Add-Member -MemberType NoteProperty -Name 'SubNet' -Value $Subnets.name
            $SiteInfo += $SiteObject
            $i++
            Write-Progress -Activity 'Gathering list of all sites and site info...' -Status "$i of $($sites.count) completed." `
                -PercentComplete (($i / $($sites.count)) * 100)
        }
    }
    END{
        Write-Output $Siteinfo
    }
}
