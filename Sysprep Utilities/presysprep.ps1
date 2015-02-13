set-itemproperty -path registry::HKEY_LOCAL_MACHINE\SYSTEM\Setup\Status\SysprepStatus -name CleanupState -value 2

set-itemproperty -path registry::HKEY_LOCAL_MACHINE\SYSTEM\Setup\Status\SysprepStatus -name GeneralizationState -value 7

msdtc -uninstall

Start-Sleep -s 10

msdtc -install 