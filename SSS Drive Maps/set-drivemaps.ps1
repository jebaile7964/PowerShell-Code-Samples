# replace PASSWORD, USERNAME, and SERVERNAME for the script to work.

BEGIN{
    $pass="PASSWORD"|ConvertTo-SecureString -AsPlainText -Force
    $Cred = New-Object System.Management.Automation.PsCredential("USERNAME",$pass)
    $logname = "drivemaplog.txt"
    $dir = "c:\log"
    $log = join-path -Path $dir -ChildPath $logname
    
    if((test-path $dir) -eq $false){
        md c:\log
    }
    if((test-path $log) -eq $false){
        new-item -Name $logname -Path $dir -ItemType file
    }

    $drivearray = @()
    $driveletter = @("I","O","T","S","U")
    $name = @("APPS","ClIENTELE","DOCS","STORAGE","USERS")
    $date = get-date -UFormat %m-%d-%y
    $i = 0
}
PROCESS{
    foreach ($d in $driveletter){
        $drive = New-Object -TypeName system.object
        $drive | Add-Member -MemberType NoteProperty -Name "DriveLetter" -Value $d
        $drive | Add-Member -MemberType NoteProperty -Name "Name" -Value $name[$i]
        $drive | Add-Member -MemberType NoteProperty -Name "UNCPath" -Value (join-path -path \\SERVERNAME -childpath $name[$i])
        $drivearray += $drive
        $i++
    }

    $drivearray | foreach {

        try{
            # use this for testing
            # net use $_.driveletter $_.uncpath 
            net use ($_.driveletter+":") | Out-Null
            if ($LASTEXITCODE -eq "0"){
               $del = net use $($_.driveletter+":") /delete
               Add-Content -Value "$date - $del" -Path $log
            }
            if ((get-psdrive -Name ($_.driveletter)) -eq ($_.driveletter)){
                Remove-PSDrive -Name ($_.driveletter) -ErrorVariable pserror -ErrorAction Stop
            }
        }
        catch{
            if ($LASTEXITCODE -ne "0"){
                Add-Content -Value "$date - $error[0].fullyqualifiederrorid - $LASTEXITCODE" -Path $log
                }
            if($pserror[0].fullyqualifiederrorid -eq "DriveNotFound,Microsoft.PowerShell.Commands.RemovePSDriveCommand"){
                Add-Content -Value "$date - $pserror[0].fullyqualifiederrorid" -Path $log
            }
        }
        Finally{
            try{
                New-PSDrive -Name $($_.driveletter) -PSProvider FileSystem -Root $($_.uncpath) -Description "$($_.name)" -Scope Global -Persist -Credential $cred -ErrorVariable finallyerror -ErrorAction stop
            }
            catch{
                if ($finallyerror -ne $null){
                    Add-Content -Value "$date - $finallyerror[0].fullyqualifiederrorid" -Path $log
                }
            }
        }
    }
}
END{}
