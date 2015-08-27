Function New-SssRdpOuConfig{
    Param( $PrimaryServerName,
           $FailoverServerName,
           $FailoverDriveLetter,
           $OuName )
    BEGIN{
        $Description = "PrimaryServer= $PrimaryServerName; FailoverServer= $FailoverServerName; FailoverDriveLetter= $FailoverDriveLetter"
        $ParentOu = Get-ADOrganizationalUnit -Filter * -Properties * | where-object distinguishedname -eq 'OU=Remote Desktop User Organizations,DC=suburbandomain2,DC=com'
    }
    PROCESS{
        if ((Get-ADOrganizationalUnit -Filter {name -eq $OuName}) -eq  $false){
            New-ADOrganizationalUnit -Description $Description -DisplayName $OuName -Name $OuName -Path $($ParentOu.distinguishedname)
        }
        else{
            Write-Host -ForegroundColor Red 'Warning: OU already exists.'
        }
    }
    END{
        Get-ADOrganizationalUnit -Filter * -Properties * | Where-Object name -Match $OuName
    }

}

Function New-SssCompanySecurityGroups{
    Param( $UserGroupName,
           $OuName )
    BEGIN{
        $OuInfo = Get-SssOuRdpInfo | Where-Object ouname -Match $OuName
    }
    PROCESS{
        New-ADGroup -Name $UserGroupName -GroupScope Global -Path $($OuInfo.distinguishedname)
        Add-ADGroupMember 'SSS Remote users' -Members $UserGroupName
        Add-ADGroupMember 'Remote Desktop Servers' -Members $OuInfo.primaryserver  
        $PrimarySession = New-PSSession $OuInfo.primaryserver
        $PrimaryScriptBlock = { $RemoteGroup = [ADSI]("WinNT://suburbandomain2/$using:UserGroupName") 
                                $AddGroup = [ADSI]("WinNT://$($using:OuInfo.primaryserver)/Remote Desktop Users") 
                                $AddGroup.PSBase.Invoke("Add",$RemoteGroup.PSBase.Path)}
        $Primary = Invoke-Command -Session $PrimarySession -ScriptBlock $PrimaryScriptBlock
        $FailSession = New-PSSession $OuInfo.failoverserver
        $FailScriptBlock = { $RemoteGroup = [ADSI]("WinNT://suburbandomain2/$using:UserGroupName") 
                             $AddGroup = [ADSI]("WinNT://$($using:OuInfo.failoverserver)/Remote Desktop Users") 
                             $AddGroup.PSBase.Invoke("Add",$RemoteGroup.PSBase.Path)}
        $Failover = Invoke-Command -Session $FailSession -ScriptBlock $FailScriptBlock
    }
    END{
        $PrimarySession | Remove-PSSession
        $FailSession | Remove-PSSession
        Get-ADGroup -Filter * -Properties * | Where-Object name -match $UserGroupName
        Get-ADGroup -Filter * -Properties * | Where-Object members -Match $OuInfo.primaryserver
        Write-Output $Primary
        Write-Output $Failover
    }
}

Function Get-SssRdpGroupInfo{
    BEGIN{
        $Groups = Get-ADGroup -Filter * -Properties * | Where-Object distinguishedname -match 'OU=Remote Desktop User Organizations,DC=suburbandomain2,DC=com'
    }
    PROCESS{}
    END{
        Write-Output $Groups | select name,distinguishedname,members
    }
}

Function Get-SssOuRdpInfo{
    BEGIN{
        $OuObjects = Get-ADOrganizationalUnit -Filter * -Properties * | Where-Object distinguishedname -Match 'OU=Remote Desktop User Organizations,DC=suburbandomain2,DC=com'
        $OuInfo = @()
    }
    PROCESS{
        foreach($o in $OuObjects){
            $Obj = New-Object -TypeName psobject
            $Obj | Add-Member -MemberType NoteProperty -Name 'OuName' -Value $o.name
            $Obj | Add-Member -MemberType NoteProperty -Name 'DistinguishedName' -Value $o.distinguishedname
            $StringToProcess = $o.description
            $Array = $StringToProcess.split(';')
            $PrimaryServer = $Array[0] -replace 'PrimaryServer= ',''
            $PrimaryServer = $PrimaryServer.trim(' ')
            $FailoverServer = $Array[1] -replace 'FailoverServer= ',''
            $FailoverServer = $FailoverServer.trim(' ')
            $FailoverDrive = $Array[2] -replace 'FailoverDriveLetter= ',''
            $FailoverDrive = $FailoverDrive.trim(' ')
            $Obj | Add-Member -MemberType NoteProperty -Name 'PrimaryServer' -Value $PrimaryServer
            $Obj | Add-Member -MemberType NoteProperty -Name 'FailoverServer' -Value $FailoverServer
            $Obj | Add-Member -MemberType NoteProperty -Name 'FailoverDrive' -Value $FailoverDrive
            $OuInfo += $Obj
        }
    }
    END{
        Write-Output $OuInfo
    }
}

Function Set-SssOuRdpPermissions{
    Param( $OuName,
           $GroupName )
    BEGIN{
        $Groups = Get-SssRdpGroupInfo | Where-Object name -Match $GroupName
        $OuInfo = Get-SssOuRdpInfo | Where-Object name -Match $OuName
    }
    PROCESS{
        $PrimarySession = New-PSSession $($OuInfo.primaryserver)
        $PrimaryScriptBlock = { if((Test-Path 'D:') -eq $true ){
                                    $Acl = Get-Acl d:
                                    $Ar = New-Object system.security.accesscontrol.filesystemaccessrule($($using:Groups.name),'FullControl','Allow')
                                    $Acl.SetAccessRule($Ar)
                                    Set-Acl d: $Acl }}
        $Primary = Invoke-Command -Session $Session -ScriptBlock $PrimaryScriptBlock
        $FailSession = New-PSSession $($OuInfo.failoverserver)
        $FailScriptBlock = { if((test-path $($OuInfo.failoverdrive) -eq $true)){
                                $Acl = get-acl $($OuInfo.failoverdrive)
                                $Ar = New-Object system.security.accesscontrol.filesystemaccessrule($($using:Groups.name),'FullControl','Allow')
                                $Acl.SetAccessRule($Ar)
                                Set-Acl $using:OuInfo.failoverdrive $Acl }}
        $Failover = Invoke-Command -Session $FailSession -ScriptBlock $FailScriptBlock
    }
    END{
        $PrimarySession | Remove-PSSession
        $FailSession | Remove-PSSession
        Write-Output $Primary
        Write-Output $Failover
    }
}

Function New-SssRdpUser{
    Param( $FirstName,
           $LastName,
           $OuName )
    BEGIN{
        $OuInfo = Get-SssOuRdpInfo | Where-Object name -match $OuName
        $Group = Get-SssRdpGroupInfo | Where-Object distinguishedname -Match $OuInfo.distinguishedname
        $Name = $FirstName + ' ' + $LastName
        $SamAccountName = $FirstName + $LastName
        $userPrincipalName = $SamAccountName + '@suburbandomain2.com'
    }
    PROCESS{
        if((Get-ADUser -Filter {samaccountname -eq $SamAccountName}) -eq $null){
            New-ADUser -AccountPassword (ConvertTo-SecureString -AsPlainText -String 'Propane1' -Force) -GivenName $FirstName -Surname $LastName `
                 -Name $Name -SamAccountName $SamAccountName -PasswordNeverExpires
            Add-ADGroupMember $Group.samaccountname $SamAccountName
        }
        else{
            Write-host -ForegroundColor Red 'WARNING: SamAccountName already exists.'
        }
    }
    END{}
}

Function New-SssCloudCustomerConfiguration{
    Param( $CsvPath,
           $OuName,
           $GroupName,
           $PrimaryServer,
           $FailoverServer,
           $FailoverDriveLetter )
    BEGIN{
        $Csv = Import-Csv $CsvPath
        $NewUserList = @()
    }
    PROCESS{
        $Ou = New-SssRdpOUConfig -PrimaryServerName $PrimaryServer -FailoverServerName $FailoverServer -FailoverDriveLetter $FailoverDriveLetter -OuName $OuName
        $Group = New-SssCompanySecurityGroups -UserGroupName $GroupName -OuName $Ou.name
        foreach ($c in $Csv){
            $user = New-SssRdpUser -FirstName $($c.FirstName) -LastName $($c.LastName) -OuName $($Ou.name)
            $NewUserList += $user
        }

    }
    END{
        Write-Output $Ou
        Write-Output $Group
        Write-Output $NewUserList
    }
}

Function Set-SssOuDescriptions{
    Param( $CsvPath )
    BEGIN{
        $Csv = Import-Csv $CsvPath
    }
    PROCESS{
        foreach ($c in $Csv){
            $Ou = Get-ADOrganizationalUnit -Filter * -Properties * | Where-Object name -eq $($c.ouname)
            $Ou.description = "PrimaryServer= $($c.PrimaryServer);FailoverServer= $($c.FailoverServer); FailoverDriveLetter= $($c.FailoverDriveLetter)"
            Set-ADOrganizationalUnit -Instance $Ou
        }
    }
    END{
        Get-SssOuRdpInfo
    }
}
