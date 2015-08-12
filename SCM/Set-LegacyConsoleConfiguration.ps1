$scriptblock = { $checkwin10 = Gcim win32_operatingsystem
                 if ($checkwin10.Name -notmatch 'Windows 10'){
                     Write-Host 'No update needed.  Operating system must be Windows 10.' -ForegroundColor Green
                 }
                 else{
                     if ((Get-WindowsOptionalFeature -Online -featurename ntvdm).state -ne 'enabled'){
                         Enable-WindowsOptionalFeature -Online -FeatureName ntvdm
                         write-host 'NTVDM.exe has been installed.' -ForegroundColor Green
                     }
                     elseif((Get-WindowsOptionalFeature -Online -FeatureName ntvdm).state -eq 'enabled'){
                         Write-Host 'NTVDM is already enabled.' -ForegroundColor DarkGreen
                     }
                      
                     if((Get-ItemProperty -Path HKCU:\Console).forcev2 -eq 1){
                         Set-ItemProperty -Path HKCU:\Console -Name forcev2 -Value 0
                     }
                     elseif((Get-ItemProperty -Path HKCU:\Console).forcev2 -eq 0){
                         Write-Host 'Legacy Console is already enabled.' -ForegroundColor DarkGreen
                     }
                      
                     Restart-Computer -Confirm
                  }
                }

If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")){
    Start-Process powershell -ArgumentList "-command $scriptblock" -verb RunAs
}
