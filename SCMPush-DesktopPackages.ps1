$scriptblock = {choco.exe install adobereader -y
                choco.exe install openoffice -y}

$servers = Get-ADComputer -Filter * -Properties * | Where-Object name -match 'RDP'
foreach ($s in $servers){
    $session = new-pssession $s
    Invoke-Command -ScriptBlock $scriptblock -Session $session
}
