Function Set-SSSSiteDNSClientConfiguration {
    BEGIN{
        $AllSites = Get-SSSCloudSitesInfo
        $KansasSite = $AllSites | Where-Object -match 'Kansas'
        $DallasSite = $AllSites | Where-Object -match 'Dallas'
        $RDPServer = Get-SSSRDPServersInfo
    }
    PROCESS{
        foreach ($r in $RDPServer){
            $Site = $AllSites | Where-Object sitename -eq $r.site
            if ($r.sitequerysuccessful -eq $true -and $Site.sitename -ne $KansasSite.sitename){
                if ($r.primarydns -ne $site.dnsip -and $r.secondarydns -ne $kansassite.dnsip){
                    $ScriptBlock = { $SetAdapter = gwmi win32_networkadapterconfiguration | Where-Object ipaddress -match $($r.ipaddress)
                                     $DNSServers = "$($site.dnsip)","$($KansasSite.dnsip)"
                                     $SetAdapter.SetDnsServerSearchOrder($DNSServers)
                                     gwmi win32_networkadapterconfiguration | Where-Object ipaddress -match $($r.ipaddress) `
                                     | select description,ipaddress,dnsserversearchorder }               
                }  
            }
            elseif($r.sitequerysuccessful -eq $true -and $Site.sitename -eq $KansasSite.sitename){
                $ScriptBlock = { $SetAdapter = gwmi win32_networkadapterconfiguration | Where-Object ipaddress -match $($r.ipaddress)
                                    $SetAdapter.SetDnsServerSearchOrder("$($site.dnsip)","$($DallasSite.dnsip)")
                                    gwmi win32_networkadapterconfiguration | Where-Object ipaddress -match $($r.ipaddress) `
                                    | select description,ipaddress,dnsserversearchorder }               
            }
            elseif($r.sitequerysuccessful -eq $false){
                Write-host -ForegroundColor Yellow "$($r.name) does not have complete Site information and will be skipped."
            }
            $Session = New-PSSession $r.name
            $DnsSettingsChange = Invoke-Command -Session $Session -ScriptBlock $ScriptBlock 
        }
    }
    END{
        Write-Output $DnsSettingsChange
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
            }
            else {
                $RDPServerObject | Add-Member -MemberType NoteProperty -Name 'SiteQuerySuccessful' -Value $false
            }
            $Session = New-PSSession $r.name
            $ScriptBlock = { gwmi win32_networkadapterconfiguration | select description,ipaddress,dnsserversearchorder }
            $AdapterInfo = Invoke-Command -Session $Session -ScriptBlock $ScriptBlock
            $RdpServerObjectAdapterInfo = $AdapterInfo | Where-Object ipaddress -match $r.ipv4address
            $RdpServerObjectHamachiInfo = $AdapterInfo | Where-Object description -match 'Hamachi'
            $RDPServerObject | add-member -MemberType NoteProperty -Name 'HamachiAddress' -Value $RdpServerObjectHamachiInfo.ipaddress[0]
            $RDPServerObject | add-member -MemberType NoteProperty -Name 'PrimaryDns' -Value $RdpServerObjectAdapterInfo.dnsserversearchorder[0]
            $RDPServerObject | Add-Member -MemberType NoteProperty -Name 'SecondaryDns' -Value $RdpServerObjectAdapterInfo.dnsserversearchorder[1]
            $RDPVMArray += $RDPServerObject
            $j++
            $i++
            Write-Progress -Activity 'Gathering RDP Server information.  This will take about a minute...' -Status `
                "Completed $i of $($RDPVM.count) Queries" -PercentComplete (($i/$rdpvm.count) * 100)
        }
    }
    END{
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
