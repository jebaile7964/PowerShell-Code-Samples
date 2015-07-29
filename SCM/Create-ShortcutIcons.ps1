Function New-ShortcutIcons{
<#
.NAME
    New-Shortcuts
.AUTHOR
    Jonathan Bailey
.SYNOPSIS
    Creates shortcuts corresponding to the proper workstation IDs.
.DESCRIPTION
    Can either pull shortcut IDs from a CSV, or from a set of IDs provided as a parameter.
.EXAMPLE
    New-Shortcuts -IDName AA,A1,A2 -RPGDirectory "I:\RPG" -Version "SSS" -Destination "I:\icons"
.EXAMPLE
    New-Shortcuts -CSV "D:\icons.csv" -RPGDirectory "D:\RPG" -Version "Propane" -Destination "D:\icons"
.INPUTS
    Can either take indivdual or multiple WSIDs, or a CSV file with WSIDs.  If using a CSV, please label
    the column WSID.
.OUTPUTS
    Creates a shortcut link in the provided destination folder.
.COMPONENT
    This CMDlet is part of SSSCMDlets Module.
#>
    [CmdletBinding(DefaultParameterSetName ='WSID', 
                   SupportsShouldProcess=$true, 
                   PositionalBinding=$false
                  )]
    Param
    (
        # Used in declaring WSID manually.
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=0,
                   ParameterSetName='WSID')]
        $IDName,

        [Parameter( Mandatory = $true,
                    ValueFromPipeline = $true,
                    ValueFromPipelineByPropertyName = $true,
                    Position = 1
                  )]
        $RPGDirectory,

        # Choose SSS or Propane
        [Parameter( Mandatory = $true,
                    ValueFromPipeline = $false,
                    ValueFromRemainingArguments = $false,
                    Position = 2
                  )]
        [ValidateSet("SSS","Propane")]
        $Version,

        [Parameter( Mandatory = $true,
                    ValueFromPipeline = $true,
                    ValueFromRemainingArguments = $false,
                    Position = 3
                  )]
        [String]
        $Destination,

        # Param3 help description
        [Parameter( ParameterSetName='CSV',
                    Mandatory = $true,
                    ValueFromPipeline = $true,
                    ValueFromRemainingArguments = $false,
                    Position = 4
                  )]
        [String]
        $CSV
    )

    Begin{
        $WSID = @()
        Set-Location $Destination
    }
    Process{
        If ($CSV.Length -gt 0){
            $CSVar = Import-Csv $CSV
            $CSVar | foreach {
                $WSID += $_.WSID
            }
        }
        If ($IDName.Length -gt 0){
            $IDName | foreach {
                $WSID += $_
            }
        }
        If($Version -eq "SSS"){
            $WorkDir = Join-Path $RPGDirectory -ChildPath "#library"
            $RPGProgram = Join-Path $WorkDir -ChildPath "b36run.exe"
            $IconName = "SSS"
        }
        If ($Version -eq "Propane"){
            $WorkDir = Join-Path $RPGDirectory -ChildPath "VBLib"
            $RPGProgram = Join-Path $WorkDir -ChildPath "propane.exe"
            $IconName = "Propane"
        }

        # Create a Shortcut with Windows PowerShell
        $i = 0
        $WSID | foreach {
            $TargetFile = $RPGProgram
            $ShortcutFile = $Destination + "\" + $IconName + " " + $WSID[$i] + ".lnk"
            $WScriptShell = New-Object -ComObject WScript.Shell
            $Shortcut = $WScriptShell.CreateShortcut($ShortcutFile)
            $Shortcut.TargetPath = $TargetFile
            $Shortcut.Arguments = $WSID[$i]
            $Shortcut.WorkingDirectory = $WorkDir
            $Shortcut.Save()
            $i++
        }
    }
    END{}
}
