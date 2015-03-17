# This script creates RDP icons based on the content of a CSV file called "user list template.csv",
# and the content of a template RDP file called propanetest.rdp.

# Prompt user to browse the csv file for import into the pipeline.
$error.Clear()
Function Get-FileName($initialDirectory){
   
    [void][System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")
    [void][System.Reflection.Assembly]::LoadWithPartialName("System.windows.window")

    # Create a open file dialog box.  User finds csv file to use for data import.
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.title = "Please find a valid CSV file to Create Cloud icons:"
    $OpenFileDialog.initialDirectory = $initialDirectory
    $OpenFileDialog.filter = "All files (*.*)| *.*"
    $result = $OpenFileDialog.ShowDialog()
    $OpenFileDialog.filename

    if ($result -eq [System.Windows.Forms.DialogResult]::Cancel){
        throw "Program Cancelled."
    }
}

# prompt user for ip/dns address input.
Function get-ip
{
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 

    # Creates a message box that accepts dns/ip address input.
    $objForm = New-Object System.Windows.Forms.Form
    $objForm.Text = "User Input Required"
    $objForm.Size = New-Object System.Drawing.Size(300,200) 
    $objForm.StartPosition = "CenterScreen"

    $objForm.KeyPreview = $True
    $objForm.Add_KeyDown({
        if ($_.KeyCode -eq "Enter") {
            $objForm.DialogResult = [System.Windows.Forms.DialogResult]::OK
        }
    })
    $objForm.Add_KeyDown({
        if ($_.KeyCode -eq "Escape"){
            $objForm.Close()
        }
    })

    $OKButton = New-Object System.Windows.Forms.Button
    $OKButton.Location = New-Object System.Drawing.Size(75,120)
    $OKButton.Size = New-Object System.Drawing.Size(75,23)
    $OKButton.Text = "OK"
    $OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $objForm.Controls.Add($OKButton)

    $CancelButton = New-Object System.Windows.Forms.Button
    $CancelButton.Location = New-Object System.Drawing.Size(150,120)
    $CancelButton.Size = New-Object System.Drawing.Size(75,23)
    $CancelButton.Text = "Cancel"
    $CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $objForm.Controls.Add($CancelButton)

    $objLabel = New-Object System.Windows.Forms.Label
    $objLabel.Location = New-Object System.Drawing.Size(10,20) 
    $objLabel.Size = New-Object System.Drawing.Size(280,40) 
    $objLabel.Text = "Please enter the DNS address of the server you want to connect to:"
    $objForm.Controls.Add($objLabel) 

    $objTextBox = New-Object System.Windows.Forms.TextBox 
    $objTextBox.Location = New-Object System.Drawing.Size(10,70) 
    $objTextBox.Size = New-Object System.Drawing.Size(260,20) 
    $objForm.Controls.Add($objTextBox) 

    $objForm.Topmost = $True

    $objForm.Add_Shown({$objForm.Activate()})
    $result = $objForm.ShowDialog()
    $objTextBox.text

    if ($result -eq [System.Windows.Forms.DialogResult]::Cancel){
        throw "Program Cancelled."

    }
}

# Creates the new RDP icons based on the input of the CSV and the RDP template icon.
function create-icons{

    # Insert user entered IP into pipeline.
    $ip = get-ip
    # Sets user entered IP into new file called propanehasip.rdp.

    $rdparray = @(
        "redirectclipboard:i:1",
        "redirectposdevices:i:0",
        "redirectprinters:i:1",
        "redirectcomports:i:1",
        "redirectsmartcards:i:1",
        "devicestoredirect:s:*",
        "drivestoredirect:s:*",
        "redirectdrives:i:1",
        "session bpp:i:32",
        "span monitors:i:1",
        "prompt for credentials on client:i:1",
        "remoteapplicationmode:i:1",
        "server port:i:3389",
        "authentication level:i:0",
        "allow font smoothing:i:1",
        "promptcredentialonce:i:1",
        "gatewayusagemethod:i:2",
        "gatewayprofileusagemethod:i:0",
        "gatewaycredentialssource:i:0",
        "full address:s:$ip",
        "alternate shell:s:||propane",
        "remoteapplicationprogram:s:||propane",
        "gatewayhostname:s:",
        "remoteapplicationname:s:propane",
        "remoteapplicationcmdline:s:INSERTWSIDHERE"
    )

    $username = @()
    $import = import-csv $csv

    Write-Host "Creating Directories..." -ForegroundColor Yellow
    cd $env:homedrive\$env:HOMEPATH
    if (!(test-path (".\icons"))){
        md icons
    }
    $import | ForEach-Object { 
        Try{
            $error.clear()
            # Creates directories based on the userName field.
            $username = $_.firstname + $_.lastname
            md icons\$username -ErrorAction stop
        }
        Catch{
            if ($error[0].FullyQualifiedErrorId -eq "DirectoryExist,Microsoft.PowerShell.Commands.NewItemCommand"){
                Write-Host "Directories exist, performing cleanup..." -ForegroundColor Yellow
                Remove-Item -Path .\icons\$username -Recurse -Force
                md .\icons\$username
                }
        }
        finally{
            # Creates icons based on $rdparray and WSID fields.
            $rdp1 = $rdparray -replace 'remoteapplicationcmdline:s:INSERTWSIDHERE',"remoteapplicationcmdline:s:$($_.wsid1)" | set-content ".\icons\$username\Propane $($_.wsid1).rdp"
            $rdp2 = $rdparray -replace 'remoteapplicationcmdline:s:INSERTWSIDHERE',"remoteapplicationcmdline:s:$($_.wsid2)" | set-content ".\icons\$username\Propane $($_.wsid2).rdp"
        }
    }
}

Try{
    $error.Clear()
    $csv = Get-FileName -initialDirectory $HOME
    create-icons
}
Catch{
    if ($error[0].FullyQualifiedErrorId -eq "Program Cancelled."){
        [System.Windows.Forms.MessageBox]::Show("Program Cancelled.",
            [System.Windows.Forms.Form]::ActiveForm
        )
    }
}
