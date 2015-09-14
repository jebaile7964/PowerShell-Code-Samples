# Installation Functions

# These functions install base dependencies which the rest of the deployment depends on.

Function Install-SSSChocolatey{
    BEGIN{
        $DeploymentDependencies = Get-SSSChocoInfo
        $ExecPolicy = Get-ExecutionPolicy
    }
    PROCESS{
        if ($ExecPolicy -eq 'Restricted'){
            Set-ExecutionPolicy -ExecutionPolicy Bypass
        }
        if ($DeploymentDependencies.chocolatey -eq $false){
            iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))
        }
        else{
            Write-Host -ForegroundColor Yellow 'ATTENTION: Chocolatey is already installed!'
        }
    }
    END{
        $CheckChoco = Get-SSSDeployDependencies
        if (($CheckChoco.isinstalled | Where-Object displayname -eq 'Chocolatey') -eq $false){
            Write-Host -ForegroundColor Red 'Chocolatey could not be installed.'
        }
        Write-Output $CheckChoco
    }
}

Function Install-SSSGit{
    BEGIN{
        $DeploymentDependencies = Get-SSSInstalledProgramsInfo
    }
    PROCESS{
        if($DeploymentDependencies.chocolatey -eq $false){
            Install-SSSChocolatey
        }
        if($DeploymentDependencies.Git -eq $false){
            choco.exe install git -y
        }
        else{
            Write-Host -ForegroundColor Yellow 'ATTENTION: Git is already installed.'
        }
    }
    END{
        $CheckGit = Get-SSSDeployDependencies
        if(($CheckGit.isinstalled | where-object name -match 'Git') -eq $false){
            Write-Host -ForegroundColor Red 'Git could not be installed.'
        }
        Write-Output $CheckGit
    }
}

Function Install-SssPowerShell{
    BEGIN{
        $HostInfo = Get-Host
    }
    PROCESS{
        if ($HostInfo.Version -lt '3.0' -and (gwmi win32_operatingsystem).version -le '6.0'){
            choco.exe install wmf3 -version 3.0.20121027 -y
        }
        if ($HostInfo.Version -lt '3.0' -and (gwmi win32_operatingsystem).version -ge '6.1'){
            choco.exe install powershell -y
        }
        else{
            Write-Host -ForegroundColor Yellow 'Attention: PowerShell Does not need to be upgraded.'
        }
    }
    END{
        get-host
    }
}

Function Install-SSSDotNet{
    BEGIN{
        $DeploymentDependencies = Get-SSSInstalledProgramsInfo
    }
    PROCESS{
        if($DeploymentDependencies.chocolatey -eq $false){
            Install-SSSChocolatey
        }
        if($DeploymentDependencies.DotNet45 -eq $false){
            choco.exe install dotnet4.5 -y
        }
        else{
            Write-Host -ForegroundColor Yellow 'ATTENTION: .Net 4.5 is already installed!'
        }
    }
    END{
        $CheckDotNet = Get-SSSDeployDependencies
        if (($CheckDotNet.isinstalled | where-object name -match '.net' -and version -gt '4.0')  -eq $false){
            Write-Host -ForegroundColor Red '.Net 4.5 could not be installed.'
        }
        Write-Output $CheckDotNet
    }
}

Function Install-SSSReportViewer{
    BEGIN{
        $DeploymentDependencies = Get-SSSInstalledProgramsInfo
    }
    PROCESS{
        if($DeploymentDependencies.chocolatey -eq $false){
            Install-SSSChocolatey
        }
        if($DeploymentDependencies.ReportViewer2012 -eq $false){
            choco.exe install reportviewer.2012 -y
        }
        else{
            Write-Host -ForegroundColor Yellow 'ATTENTION: Report Viewer for SQL Server 2012 is already installed.'
        }
    }
    END{
        $checkReportViewer = Get-SSSDeployDependencies
        if (($checkReportViewer.isinstalled | Where-Object name -match 'Report Viewer 2012') -eq $false){
            Write-Host -ForegroundColor Red 'Report Viewer for SQL Server 2012 Could not be installed.'
        }
        Write-Output $checkReportViewer
    }
}

Function Install-SSSCLRTypes{
    BEGIN{
        $DeploymentDependencies = Get-SSSInstalledProgramsInfo
    }
    PROCESS{
        if($DeploymentDependencies.chocolatey -eq $false){
            Install-SSSChocolatey
        }
        if($DeploymentDependencies.CLRTypes -eq $false){
            choco.exe install sql2012.clrtypes -y
        }
        else{
            Write-Host -ForegroundColor Yellow 'ATTENTION: SQL CLR Types for 2012 is already installed.'
        }
    }
    END{
        $CheckCLRTypes = Get-SSSDeployDependencies
        if (($CheckCLRTypes.isinstalled | where-object name -match 'CLR Types for SQL Server 2012') -eq $false){
        Write-Host -ForegroundColor Red 'CLR Types for SQL Server 2012 could not be installed.'
        }
        Write-Output $CheckCLRTypes
    }
}

Function Install-SSSBaby36{
    Param( $InstallPath,
           [ValidateSet('Full', 'Client')]
           $BabyVersion )
    BEGIN{
        $DeploymentDependencies = Get-SSSInstalledProgramsInfo
    }
    PROCESS{
        if($DeploymentDependencies.git -eq $false){
            Install-SSSGit
        }
        if($DeploymentDependencies.baby36 -eq $false){
            Set-Location $InstallPath
            git clone https://jebaile7964@bitbucket.org/jebaile7964/baby-36.git --depth=1
            $Choice = Read-Host 'WARNING: the Baby 36 Install is a GUI based, wizard driven install.  Continue? <Y/N>'
            if ($Choice -eq 'Y'){
                $TBDPath = Join-Path $InstallPath -ChildPath sss.net\baby36.sno
                $TBD = Get-Content $TBDPath
                $TBD | clip
                
                Write-Host -ForegroundColor 'Yellow TBD license information is stored on the clipboard!  Paste to use it!'
                Pause
                
                if ($BabyVersion -eq 'Full'){
                    $Setup = Join-Path $InstallPath babyfull\setup.exe
                }
                elseif($BabyVersion -eq 'Client'){
                    $Setup = Join-Path $InstallPath babyclient\setup.exe
                }
                
                Invoke-Command -ScriptBlock {$Setup}
            }
        }
        else{
            Write-Host -ForegroundColor Yellow 'ATTENTION: Baby 36 is already installed.'
        }
    }
    END{
        $CheckBaby36 = Get-SSSDeployDependencies
        if (($CheckBaby36.isinstalled | where-object name -match 'Baby 36') -eq $false){
            Write-Host -ForegroundColor Red 'Baby 36 Could not be installed.'
        }
        Write-Output $CheckBaby36
    }
}

Function Install-SSSAdobereader{
    BEGIN{
        $DeploymentDependencies = Get-SSSInstalledProgramsInfo
    }
    PROCESS{
        if ($DeploymentDependencies.chocolatey -eq $false){
            Install-SSSChocolatey
        }
        if($DeploymentDependencies.adobereader -eq $false -and (gwmi win32_operatingsystem).version -le '6.0.6002'){
            choco.exe install adobereader -version 11.0.10 -y
        }
        elseif($DeploymentDependencies.adobereader -eq $false -and (gwmi win32_operatingsystem).version -gt '6.0.6002'){
            choco.exe install adobereader -y
        }
        else{
            Write-Host -ForegroundColor Yellow 'ATTENTION: Adobe Reader is already installed.'
        }
    }
    END{
        $CheckAdobeReader = Get-SSSDeployDependencies
        if (($CheckAdobeReader.isinstalled | Where-Object name -Match 'Adobe Reader XI') -eq $false){
            Write-Host -ForegroundColor Red 'Adobe Reader could not be installed.'
        }
    }
}

Function Install-SSSOpenOffice{
    BEGIN{
        $DeploymentDependencies = Get-SSSInstalledProgramsInfo
    }
    PROCESS{
        if ($DeploymentDependencies.chocolatey -eq $false){
            Install-SSSChocolatey
        }
        if ($DeploymentDependencies.openoffice -eq $false){
            choco.exe install openoffice -y
        }
        else{
            write-host -ForegroundColor Yellow 'Attention: OpenOffice could not be installed.'
        }
    }
    END{
        $CheckOpenOffice = Get-SSSDeployDependencies
        if (($CheckOpenOffice.isinstalled | Where-Object name -Match 'OpenOffice') -eq $false){
            Write-Host -ForegroundColor Red 'OpenOffice could not be installed.'
        }
    }
}

Function Install-MapPoint{
    [CmdletBinding(DefaultParameterSetName="Install",
                   SupportsShouldProcess=$true,
                   PositionalBinding=$true)]
    Param( 
           [Parameter(Mandatory=$true,
                     ValueFromPipelineByPropertyName=$true,
                     Position=0)]
           $dir       
          )
    BEGIN{
        $DeploymentDependency = Get-SSSInstalledProgramsInfo
    }
    PROCESS{
        if ( $DeploymentDependency.mappoint -ne "Microsoft Mappoint North America 2006"){
            msiexec /i $dir\map2006\mappoint\msmap\data.msi /qn /norestart /le c:\mappointlog.txt OFFICE_INTEGRATION=0
        }
        else{
            write-host -ForegroundColor Yellow 'ATTENTION:  Mappoint is already installed.'
        }
    }
    END{
        $CheckMapPoint = Get-SSSDeployDependencies
        if (($CheckMapPoint.isinstalled | Where-Object -Match 'Microsoft Mappoint North America 2006') -eq $false){
            Write-Host -ForegroundColor Red 'ATTENTION:  MapPoint cannot be installed.'
        }
    }
}

Function Import-SSSModules{
    Param( [ValideSet('SssDeployment','SssDnsSiteTools','SSSNewInstallModule')]
            $SSSModuleName )
    BEGIN{
        $PSModuleLocation = $env:PSModulePath
        $PSModuleLocation = $PSModuleLocation.split(';')
        $Dependencies = Get-SSSInstalledProgramsInfo
        if( ($Dependencies.isInstalled | Where-Object displayname -eq 'git') -eq $false ){
            Install-SSSGit
        }
    }
    PROCESS{
        foreach($p in $PSModuleLocation){
            if ($p -eq 'C:\Program Files\windowspowershell\modules'){
                Set-Location $p
                git.exe clone $SSSModuleName --depth=1
                $path = Join-Path $p -ChildPath $SSSModuleName
                Set-SSSPathInfo -Name $SSSModuleName -Path $path
            }
        } 
    }
    END{
        Get-SSSPathInfo -Name SSSModules
    }
}

Function Set-SSSPSProfileInfo{
    BEGIN{
        $PSProfileInfo = get-SSSPSProfileInfo
    }
    PROCESS{
        if ($PSProfileInfo.psprofile -eq $false){
            New-Item -Type file -Force $profile
            $ProfileInput = @( 'if (get-executionpolicy -ne "RemoteSigned"){ set-executionpolicy remotesigned }',
                               'Set-Alias -Name NP -Value "C:\Program Files (x86)\Notepad++\notepad++.exe" -Scope global',
                               'Set-Alias -Name 7z -Value "C:\Program Files\7-Zip\7z.exe" -Scope global')
            foreach ($p in $ProfileInput){
                if ($($profile) -notmatch $p){
                    $p | Add-Content $($profile)
                }
            }
        } 
        else{
            Write-Host -ForegroundColor Green 'SSS PS Profile is already present.'
            Write-Host -ForegroundColor Green "$($profile)"
        } 
    }
    END{
            $ProfileContents = Get-Content $($profile)
            write-host $ProfileContents
    }
}

# Type Initializer Functions

# These functions are required to initialize types that are used in Propane Deployment.

function Initialize-SSSPathType{
    BEGIN{
        $isPathsInitialized = [SssTypes.SssPaths]
        $Source = @"

namespace SSSTypes{
    public class SSSPaths{
        public string FriendlyName {get;set;}
        public string Path {get;set;}
        public bool hasPath {get;set;}
        public string Source {get;set;}
        public System.DateTime AddedOn {get;set;}
    }
}
"@;
    }
    PROCESS{
        if($isPathsInitialized.IsClass -eq $null){
            add-type -Language CSharp -TypeDefinition $Source
            Write-Host 'SSSTypes.SSSPaths has been initialized.'
        }
        else{
            Write-Host 'SSSTypes.SSSPaths is already loaded.'
        }
    }
    END{
        $checkPathsInitialized = [SssTypes.SssPaths]
        Write-Output $checkPathsInitialized
    }
}

function Initialize-SSSProgramType{
    BEGIN{
        $isProgramTypeInitialized = [SssTypes.DeploymentDependency]
        $Source = @"
using System;

namespace SssTypes
{
    public class DeploymentDependency
    {
        public string DisplayName { get; set; }
        public string Source { get; set; }
        public string DisplayVersion { get; set; }
        public string Publisher { get; set; }
        public bool isInstalled { get; set; }
        private DateTime m_InstalledDate;

        public string InstalledDate
        {
            get
            {
                return m_InstalledDate.ToString();
            }
            set
            {
                string dateInput = value;
                if (dateInput.Length > 8)
                {
                    DateTime date = DateTime.Parse(dateInput);
                    m_InstalledDate = date;
                }
                else 
                {
                    Int32 year = Int32.Parse(dateInput.Substring(0, 4));
                    Int32 month = Int32.Parse(dateInput.Substring(4, 2));
                    Int32 day = Int32.Parse(dateInput.Substring(6, 2));
                    DateTime date = new DateTime(year, month, day);
                    m_InstalledDate = date;
                }
            }
        }
    }
}
"@
    }
    PROCESS{
        if($isProgramTypeInitialized.IsClass -eq $null){
            add-type -Language CSharp -TypeDefinition $Source
            write-host 'SSSTypes.DeploymentDependency has been initialized.'
        }
        else{
            Write-Host 'SSSTypes.DeploymentDependency is already loaded.'
        }
    }
    END{
        $checkIsInitialized = [SssTypes.DeploymentDependency]
        Write-Output $checkIsInitialized
    }
}

Function Set-SSSModuleManifest{
    Param( $Path,
           $SSSModule,
           $ModuleVersion,
           $Description,
           $FileList,
           $RootModule )
    BEGIN{
    }
    PROCESS{
        New-ModuleManifest -Path $Path -Author 'Jonathan Bailey' -CompanyName 'Suburban Software Systems' -RootModule `
            $SSSModule -ModuleVersion $ModuleVersion -Description $Description -PowerShellVersion '3.0' -ClrVersion '4.0' `
            -DotNetFrameworkVersion '4.0' -FileList $FileList -RootModule $RootModule
    }
    END{
        Test-ModuleManifest -Path $Path
    }
}

# Getter Functions

# These functions supply information that is important to the deployment of Propane.

Function Get-SSSDeployDependencies{
    BEGIN{
        $choco = Get-SSSChocoInfo
        $InstalledDependencies = Get-SSSInstalledProgramsInfo
        $PSProfile = get-SSSPSProfileInfo
        $WMFInfo = Get-Host
    }
    PROCESS{
        $DependencyArray = @( $choco,
                              $InstalledDependencies,
                              $PSProfile,
                              $WMFInfo )
    }
    END{
        Write-Output $DependencyArray
    }
}

Function Get-SSSChocoInfo{
    BEGIN{
        Initialize-SSSProgramType
    }
    PROCESS{
        $choco = new-object -TypeName SssTypes.DeploymentDependency
        $choco.DisplayName = 'Chocolatey'
        $choco.Source = 'www.chocolatey.org'
        $choco.Publisher = 'RealDimensions Software'
        if ((Test-Path -Path C:\ProgramData\chocolatey) -eq $true){
            $chocover = choco.exe version | select -First 1
            $choco.DisplayVersion = $chocover.trim('Chocolatey v')
            $chocodate = gci C:\ProgramData | Where-Object Name -eq 'Chocolatey'
            $choco.InstalledDate = $chocodate.CreationTime.ToString()
            $choco.isInstalled = $true
        }
        else{
            $choco.isInstalled = $false
        }
    }
    END{
        Write-Output $choco
    }
}

Function Get-SSSInstalledProgramsInfo{
    BEGIN{
        Initialize-SSSProgramType
        $Installedx64Programs = Get-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\* | `
                                 Select-Object DisplayName,DisplayVersion,Publisher,InstallDate,UrlInfoAbout
        $Installedx86Programs = Get-ItemProperty -Path HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | `
                                    Select-Object DisplayName,DisplayVersion,Publisher,InstallDate,UrlInfoAbout
        $DependencyNames = @( 'Baby 36',
                              'Git',
                              '.net Framework',
                              'Report Viewer 2012',
                              'CLR Types for SQL Server 2012',
                              '7-zip',
                              'Adobe Reader XI',
                              'OpenOffice',
                              'Microsoft Mappoint North America 2006' )
        $InstalledPrograms = @()
        $InstalledDependencies= @()
        $ProgramObjects = @()
    }
    PROCESS{
        foreach ($p in $Installedx64Programs){
            $InstalledPrograms += $p
        }
        foreach ($p in $Installedx86Programs){
            $InstalledPrograms += $p
        }
        foreach ($d in $DependencyNames){
           $match = $InstalledPrograms | Where-Object DisplayName -Match $d
           $ProgramObjects += $match
        }
        foreach ($p in $ProgramObjects){
            $Obj = New-Object -TypeName SssTypes.DeploymentDependency
            $Obj.DisplayName = $p.DisplayName
            $Obj.DisplayVersion = $p.DisplayVersion
            $Obj.InstalledDate = $p.InstallDate
            $Obj.isInstalled = $true 
            $Obj.Publisher = $p.Publisher
            $Obj.Source = $p.UrlInfoAbout
            $InstalledDependencies += $Obj
        }
    }
    END{
        Write-Output $InstalledDependencies
    }
}

function Get-SSSPathInfo {
    BEGIN{
        $SSSPathXml = 'C:\Program Files\windowspowershell\modules\SSSModules\SSSDeployment\SSSPathsInfo.xml'
    }
    PROCESS{
        if ((Test-Path $SSSPathXml) -eq $true){
            $SSSPaths = Import-Clixml $SSSPathXml
            Write-Output $SSSPaths
        }
        else{
            Write-Host -ForegroundColor Red "Warning: no XML file found at $($SSSPathXml).  Please run Import-SSSModules first."
            Write-Output $false
        }
    }
    END{}
}

Function Get-SSSPSProfileInfo{
    BEGIN{}
    PROCESS{
        if ((Test-Path $profile) -eq $false){
            Write-Host -ForegroundColor Yellow 'No PS profile found for this type of shell.'
            $SetPSProfile = $false
        }
        else{
            $PSProfileInfo = Get-Content $profile
            $ProfileInput = @( 'set-executionpolicy remotesigned',
                               'Set-Alias -Name NP -Value "C:\Program Files (x86)\Notepad++\notepad++.exe" -Scope global',
                               'Set-Alias -Name 7z -Value "C:\Program Files\7-Zip\7z.exe" -Scope global')
            while($SetPSProfile -eq $true){
                foreach ($p in $ProfileInput){
                    foreach ($ps in $PSProfileInfo){
                        if ($ps -ne $p){
                            $SetPSProfile = $false
                        } 
                    } 
                }
            }
        }
    }
    END{
        if($SetPSProfile -eq $false){
            Write-Output $false
        }
        else{

            Write-Output $true
        }
        write-host $PSProfileInfo -Separator `n
    }
}

Function Get-SSSModule {
    Param( [ValidateSet('SssDeployment','SssDnsSiteTools','SssNewInstallModule')]
           $ModuleName)

    BEGIN{
        $SSSModules = Get-Module -Name *SSS*
        $ModuleRemoteVersion = git ls-remote --tags $ModuleName | select -Last 1
    }
    PROCESS{
        if ($SSSModules.Version -notmatch $ModuleRemoteVersion){
            git clone $SSSModuleRemote --depth=1
        }
    }
    END{
        Get-Module -Name $ModuleName
    }
}

Function New-SSSHamachiSvcHelper{
    BEGIN{
        $JobName = 'Hamachi Service Start'
        $Trigger = New-JobTrigger -AtLogOn
        $Option = New-ScheduledJobOption -RunElevated -RequireNetwork
    }
    PROCESS{
        $Scriptblock = {$HamachiSvc = get-service | where-object name -match 'hamachi2svc'
                        if($HamachiSvc.status -ne 'running'){
                        restart-service hamachi2svc
}}    
    }
    END{
        Register-ScheduledJob -ScriptBlock $Scriptblock -Name $JobName -Trigger $Trigger -ScheduledJobOption `
        $Option
    }
}

Function Get-SSSPropaneReleaseInfo{
    BEGIN{
        $CurrentReleasePath = 'C:\Users\bailey.jonathan\Documents\GitHub\RUNTIME'
        $ReleasePath = 'I:\SSSAVES\RELEASES\RUNTIME'
        $Libraries = @( 'ap',
                        'gasupd',
                        'gl',
                        'inv',
                        'pay',
                        'vblib')
        $ReleaseInfo = @()
    }
    PROCESS{
        if ((Test-Path $CurrentReleasePath) -eq $false){
            Write-Host -ForegroundColor Yellow 'No Release staging folder found.  Creating...'
            md $CurrentReleasePath
        }
        if ((Test-Path $ReleasePath) -eq $false){
            Write-Host -ForegroundColor Red 'Warning: current release drive not available.'
            Get-PSDrive
        }
        else{
            Foreach ($l in $Libraries){
                $zip = $l + '.zip'
                $LibraryPath = Join-Path $ReleasePath -ChildPath $zip
                $LibraryHash = Get-FileHash $LibraryPath -Algorithm MD5
                $CurrentPath = Join-Path $CurrentReleasePath -ChildPath $zip
                $CurrentHash = Get-FileHash $CurrentPath -Algorithm MD5
                $CurrentRepo = 'https://jebaile7964@bitbucket.org/jebaile7964/' + $l + '.git'
                $LibObj = New-Object psobject
                $LibObj | Add-Member -MemberType NoteProperty -Name 'LibraryName' -Value $L
                $LibObj | Add-Member -MemberType NoteProperty -Name 'ReleasePath' -Value $LibraryPath
                $LibObj | Add-Member -MemberType NoteProperty -Name 'ReleaseHash' -Value $LibraryHash.hash
                if($CurrentPath -eq $false){
                    $LibObj | Add-Member -MemberType NoteProperty -Name 'CurrentReleaseExists' -Value $false
                }
                else{
                    $LibObj | Add-Member -MemberType NoteProperty -Name 'CurrentReleaseExists' -Value $true
                }
                $LibObj | Add-Member -MemberType NoteProperty -Name 'CurrentPath' -Value $CurrentPath
                $LibObj | Add-Member -MemberType NoteProperty -Name 'CurrentHash' -Value $CurrentHash.hash
                if ($LibraryPath.hash -eq $CurrentPath.hash){
                    $LibObj | Add-Member -MemberType NoteProperty -Name 'HashValuesMatch' -Value $true
                }
                else{
                    $LibObj | Add-Member -MemberType NoteProperty -Name 'HashValuesMatch' -Value $false
                }
                $LibObj | 
                $ReleaseInfo += $LibObj
            }
        }
    }
    END{
        Write-Output $ReleaseInfo
    }
}
