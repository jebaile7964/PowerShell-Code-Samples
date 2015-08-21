$session = New-PSSession -ComputerName $ComputerName

Invoke-Command -ScriptBlock {Import-Module ActiveDirectory} -Session $session
Import-PSSession -Module activedirectory -Session $session

$ou = Get-ADOrganizationalUnit -Filter * -Properties * | where-object name -match "$OUName"

$users = Get-ADUser -Filter * -Properties * | Where-Object distinguishedname -Match $ou.distinguishedname
$users | Select-Object -name -Property lastlogondate | Where-Object lastlogon -eq 0
