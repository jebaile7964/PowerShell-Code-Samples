$reg = Get-ItemProperty HKLM:\SYSTEM\CurrentControlSet\Control\NetworkProvider\Order | select providerorder |ft -HideTableHeaders
$reg = $reg | Out-String
$reg = $reg.split(',')
$regarray = @()
$reg | foreach { $regarray += $_ }

$i = [array]::indexof($regarray,"LanmanWorkstation")
$valuechange = $regarray[$i]
$regarray | foreach {
    while ($_ -eq "LanmanWorkstation" -and $i -ne 0){
        $oldvalue = $regarray[($i-1)]
        $i = $i-1
        $regarray[$i] = $valuechange
        $regarray[($i+1)] = $oldvalue
    
    }
}
$regarray = $regarray.Trim( )
$reg = $regarray -join ','
$reg
Set-ItemProperty -path HKLM:\SYSTEM\CurrentControlSet\Control\NetworkProvider\Order -Name providerorder -Value $reg

