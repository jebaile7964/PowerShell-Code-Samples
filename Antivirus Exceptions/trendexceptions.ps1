<#
.Author
	Jonathan Bailey
.Synopsis
   Generates a list of UNC paths to add to exclusion / exceptions lists for Antivirus.
.DESCRIPTION
   You must make sure that powershell execution policy is set to RemoteSigned in order to run this script.
   You must also run this script as an administrator.  This script will attempt to get psdrive information
   and if an error occurs, it will attempt to gather the information using net use.  If 
#>

# Gives proper formatting to error status for Get-PsDrive
$errornull = @"

Error status is Null. Using Get-PsDrive to generate UNC Path.
"@

# Attempts to generate UNC Data using Get-PsDrive
try {
    $error.clear()
    $drivemap = $null
    $test = Get-PSDrive -Name I -ErrorAction Stop
    if ($test.DisplayRoot -notcontains "\\"){
        throw "DisplayRoot does not contain a UNC path."
    }
    
    if (!$error){
        write-host $errornull -ForegroundColor Yellow
        $drivemap = Get-PSDrive -Name I | Select-Object DisplayRoot | ft -HideTableHeaders
        # Converts powershell display object to a string and trims whitespace.
        $drivemap = $drivemap | Out-String
        $drivemap = $drivemap.trim()
    }
}

# If Get-PsDrive was not used to create the drive map, Net Use is utilized instead.
catch {
    if ($error[0].FullyQualifiedErrorId -eq "GetLocationNoMatchingDrive,Microsoft.Powershell.Commands.GetPSDriveCommand" -or $error[0].FullyQualifiedErrorId -eq "DisplayRoot does not contain a UNC Path."){
        Write-Host "$error  Using Net Use to generate UNC path." -ForegroundColor Yellow
        $drivemap = net use I:
        #selects the line to use and removes all unnecessary expressions.
        $drivemap = $drivemap | select -Skip 1 -First 1
        $drivemap = $drivemap.trim("Remote name ")
    }

}

# Creates an array with the child paths and uses foreach to attach them to the UNC that's been generated.
finally{
    $array = @(
        "\rpg\",
        "\rpg\vblib",
        "\rpg\#library",
        "\rpg\#library\b36run.exe",
        "\rpg\vblib\propane.exe",
        "\rpg\vblib\update.exe",
        "\rpg\#library\oclrt.exe",
        "\rpg\#library\wsio.exe",
        "\rpg\#library\wsiostop.exe"
        )

    $exceptions = @()

    $array | foreach {

        $exceptions += Join-Path -Path $drivemap -ChildPath $_ 
        
    }

    # Sends the array to the Grid Viewer to copy into the exceptions list.
    $exceptions | Out-GridView -Title "UNC Path Exceptions"
}