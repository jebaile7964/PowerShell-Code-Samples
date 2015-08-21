$ScriptBlock = { # Is this a 64 bit process
                 function Test-Win64() {
                     return [IntPtr]::size -eq 8
                 }

                 # Is this a 32 bit process
                 function Test-Win32() {
                     return [IntPtr]::size -eq 4
                 }

                 If (-Not(Test-Path C:\SqlServer2012\sql2012adv.exe)){
	 
	                 New-Item -ItemType directory -Path C:\SqlServer2012

	                 if(Test-Win32){
		                 wget http://techguy.ws/files/sql2012adv32.exe -OutFile C:\SqlServer2012\sql2012adv.exe
	                 }

	                 if(Test-Win64){
		                 wget http://techguy.ws/files/sql2012adv64.exe -OutFile C:\SqlServer2012\sql2012adv.exe
	                 }
	
                 }	


                 $exe = 'C:\SqlServer2012\sql2012adv.exe'
                 $arguments = '/qs /ACTION=Install /ERRORREPORTING /FEATURES=SQLENGINE,REPLICATION,FULLTEXT,SSMS /ROLE=AllFeatures_WithDefaults /INSTANCENAME=MSSQLSERVER /AGTSVCACCOUNT="NT AUTHORITY\Network Service" /TCPENABLED="1" /BROWSERSVCSTARTUPTYPE="Automatic" /IACCEPTSQLSERVERLICENSETERMS /SECURITYMODE=SQL'
                 Start-Process -FilePath $exe -ArgumentList $arguments

                 pause }

If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")){
    Start-Process powershell -ArgumentList "-executionpolicy bypass -command $scriptblock" -verb RunAs
}
