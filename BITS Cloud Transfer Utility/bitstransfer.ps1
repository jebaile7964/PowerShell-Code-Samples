function create-share{
    
    Try{
        $error.Clear()
        $ShareName = Get-WmiObject -Class Win32_Share -Filter "name ='Transfer'"
        $newfolder = "d:\transfer"
        if (!(Test-Path ($newfolder))){
            New-Item -Path $newfolder -Type Directory
        }
    }
    Catch{

        if ($error[0].FullyQualifiedErrorId -eq "DriveNotFound,Microsoft.PowerShell.Commands.NewItemCommand"){
            [System.Windows.Forms.MessageBox]::Show("Default data drive not found.  Please Select a folder to share.",
                [System.Windows.Forms.form]::ActiveForm
            )

            Try{
                $newfolder = get-foldername
            }
            Catch{
                if ($error[0].FullyQualifiedErrorId -eq "Program Cancelled."){
                    [System.Windows.Forms.MessageBox]::Show("Program Cancelled.",
                        [System.Windows.Forms.Form]::ActiveForm
                    )
                }
            } 
        }
    }
    Finally{

        $Shares = [WMICLASS]”WIN32_Share”
        $user = "$env:USERDOMAIN\$env:USERNAME"
        $unc = "\\$env:COMPUTERNAME\Transfer"

        if (!($ShareName)){
            $Shares.Create($newfolder,"Transfer","0")
            $acl = Get-Acl $unc
            $permissions = $user,"FULLCONTROL","ALLOW"
            $accessrule = New-Object System.Security.AccessControl.FileSystemAccessRule $permissions
            $acl.SetAccessRule($accessrule)
            $acl | Set-Acl $unc
        }

        $acl = Get-Acl $unc
        $aclstring = $acl | Out-String

        if($aclstring -notcontains "$user"){
            $permissions = $user,"FULLCONTROL","ALLOW"
            $accessrule = New-Object System.Security.AccessControl.FileSystemAccessRule $permissions
            $acl.SetAccessRule($accessrule)
            $acl | Set-Acl $unc    
        }   
    }
}

function remove-share{

    $ShareName = Get-WmiObject -Class Win32_Share -Filter "name = 'Transfer'"
    if($ShareName -eq $true){
        $ShareName.delete()
    }
}

Function Get-FileName {   
    
    [void][System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")

    # Create a open file dialog box.  User finds csv file to use for data import.
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.Multiselect = $true
    $OpenFileDialog.title = "Please Select a file or files to Transfer:"
    $OpenFileDialog.initialDirectory = $env:HOMEPATH
    $OpenFileDialog.filter = "All files (*.*)| *.*" 
    $result = $OpenFileDialog.ShowDialog() | Out-Null
    $OpenFileDialog.FileName

    if ($result -eq [System.Windows.Forms.DialogResult]::Cancel){
        throw "Program Cancelled."
    }
}

Function get-foldername{

    [void][System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")

    $OpenFolderDialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $OpenFolderDialog.Description = "Please Select a folder to Transfer to:"
    $OpenFolderDialog.SelectedPath = $env:homedrive+$env:HOMEPATH
    $OpenFolderDialog.ShowNewFolderButton = $true
    $result = $OpenFolderDialog.ShowDialog([system.windows.forms.form]::ActiveForm) | Out-Null

    if ($result -eq [System.Windows.Forms.DialogResult]::Cancel){
        throw "Program Cancelled."
    }

}

Function get-computername{
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 

    # Creates a message box that accepts UNC Path input.
    $objForm = New-Object System.Windows.Forms.Form
    $objForm.Text = "User Input Required"
    $objForm.Size = New-Object System.Drawing.Size(300,200) 
    $objForm.StartPosition = "CenterScreen"

    $objForm.KeyPreview = $True
    $objForm.Add_KeyDown({if ($_.KeyCode -eq "Enter") 
        {$x=$objTextBox.Text;$objForm.Close()}})
    $objForm.Add_KeyDown({if ($_.KeyCode -eq "Escape") 
        {$objForm.Close()}})

    $OKButton = New-Object System.Windows.Forms.Button
    $OKButton.Location = New-Object System.Drawing.Size(75,120)
    $OKButton.Size = New-Object System.Drawing.Size(75,23)
    $OKButton.Text = "OK"
    $OKButton.Add_Click({$x=$objTextBox.Text;$objForm.Close()})
    $objForm.Controls.Add($OKButton)

    $CancelButton = New-Object System.Windows.Forms.Button
    $CancelButton.Location = New-Object System.Drawing.Size(150,120)
    $CancelButton.Size = New-Object System.Drawing.Size(75,23)
    $CancelButton.Text = "Cancel"
    $CancelButton.Add_Click({$objForm.Close()})
    $objForm.Controls.Add($CancelButton)

    $objLabel = New-Object System.Windows.Forms.Label
    $objLabel.Location = New-Object System.Drawing.Size(10,20) 
    $objLabel.Size = New-Object System.Drawing.Size(280,40) 
    $objLabel.Text = @" 
Please enter the name of the computer you want to connect to: 
EX: \\SERVER\SHARE\
"@
    $objForm.Controls.Add($objLabel) 

    $objTextBox = New-Object System.Windows.Forms.TextBox 
    $objTextBox.Location = New-Object System.Drawing.Size(10,70) 
    $objTextBox.Size = New-Object System.Drawing.Size(260,20) 
    $objForm.Controls.Add($objTextBox) 

    $objForm.Topmost = $True

    $objForm.Add_Shown({$objForm.Activate()})
    $result = $objForm.ShowDialog() | Out-Null

    if ($result -eq [System.Windows.Forms.DialogResult]::Cancel){
        throw "Program Cancelled."
    }

}

Function upload-bits{

    Try{
        
        $error.Clear()
        $module = Get-Module
        if ($module.Name -notcontains "BitsTransfer"){
        
            Import-Module BitsTransfer -Verbose

        }

        $files = Get-FileName -initialDirectory $HOME
        $computername = get-computername
        $bits = Start-BitsTransfer -Source $files -Asynchronous -Destination $computername -Priority Normal -Credential (Get-Credential) -ErrorAction stop
        $job = Start-Job -Name BitsUpload -ScriptBlock { $bits }
    }
    Catch{

        if ($error[0].FullyQualifiedErrorId -eq "Program Cancelled."){
        [System.Windows.Forms.MessageBox]::Show("Program Cancelled.",
            [System.Windows.Forms.Form]::ActiveForm
            )
        }
    }
   <# Catch{
        if ($error[0].FullyQualifiedErrorId -eq "MissingMandatoryParameter,Microsoft.PowerShell.Commands.GetCredentialCommand"){
            [System.Windows.Forms.MessageBox]::Show("Program Cancelled.",
                [System.Windows.Forms.Form]::ActiveForm
            )
        }
    }#>
}

Function download-bits{

    Try{
        $module = Get-Module
        if ($module.Name -notcontains "BitsTransfer"){
    
            Import-Module BitsTransfer -Verbose

        }

        $files = Get-FileName -initialDirectory $HOME
        $foldername = get-foldername
        $bits = Start-BitsTransfer -Source $files -Asynchronous -Destination $foldername -Priority Normal -Credential (Get-Credential) -ErrorAction stop
        $job = Start-Job -Name BitsDownload -ScriptBlock { $bits }
    }
    Catch{

        if ($error[0].FullyQualifiedErrorId -eq "Program Cancelled."){
        [System.Windows.Forms.MessageBox]::Show("Program Cancelled.",
            [System.Windows.Forms.Form]::ActiveForm
            )
        }
    }
}

Function view-bits{

    Get-BitsTransfer | Where-Object {$_.name -is "BitsDownload" -or "BitsUpload"} | Select-Object -Property  | Out-GridView

}

Function edit-bits{}

Function help-menu{}

function bits-menu {
    
    Clear-Host
    write-host @"
--------------------------------------------------
            
                BITS Transfer Menu

        1. Create a Share
        2. Remove a Share
        3. Start an Upload BITS Connection
        4. Start a Download BITS Connection
        5. View BITS Transfers
        6. Modify BITS Transfers
        7. Help
        8. Exit

--------------------------------------------------
"@

    $answer = read-host "Please Make a Selection"  

    if ($answer -eq 1){

        Clear-Host
        create-share
        bits-menu

    }

    if ($answer -eq 2){
        
        Clear-Host
        remove-share
        bits-menu
    }

    if ($answer -eq 3){
        
        Clear-Host
        upload-bits
        bits-menu

    }

    if ($answer -eq 4){
        
        Clear-Host
        download-bits
        bits-menu
    }

    if ($answer -eq 5){
        
        Clear-Host
        view-bits
        bits-menu

    }

    if ($answer -eq 6){
        
        Clear-Host
        edit-bits
        bits-menu

    }

    if ($answer -eq 7){
    
        Clear-Host
        help-menu
        
    }

    if ($answer -eq 8){exit-menu}
}

bits-menu
