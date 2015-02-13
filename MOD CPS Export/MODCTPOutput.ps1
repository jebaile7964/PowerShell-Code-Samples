<#
.Author
	Jonathan Bailey
.Synopsis
   Exports CTPOUTPT.D to the remote client's desktop folder.
.DESCRIPTION
   In order to run this script, execution policy must be set to RemoteSigned.  The script must be run as an administrator.
   The script assumes that you need to export a file from a remote server to your local desktop.create-form displays a single-select
   listbox that allows the user to select one of 5 different Modern Gas Sales Companies. Once the user makes their selection, the
   choice is processed and a file is transferred from the server to the user's desktop taking into consideration what the company ID
   is.  Once processed, a message pops up notifying the user whether or not the attempt was successful.
#>

[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 

function Get-CIDList{

    $objForm = New-Object System.Windows.Forms.Form 
    $objForm.Text = "Select a Company ID."
    $objForm.Size = New-Object System.Drawing.Size(300,200) 
    $objForm.StartPosition = "CenterScreen"

	$OKButton = New-Object System.Windows.Forms.Button
    $OKButton.Location = New-Object System.Drawing.Size(75,120)
    $OKButton.Size = New-Object System.Drawing.Size(75,23)
    $OKButton.Text = "OK"

    $OKButton.dialogresult = [System.Windows.Forms.DialogResult]::OK

    $objForm.Controls.Add($OKButton)

    $CancelButton = New-Object System.Windows.Forms.Button
    $CancelButton.Location = New-Object System.Drawing.Size(150,120)
    $CancelButton.Size = New-Object System.Drawing.Size(75,23)
    $CancelButton.Text = "Cancel"

    $objForm.Controls.Add($CancelButton)
    $objForm.CancelButton = $CancelButton
    $objLabel = New-Object System.Windows.Forms.Label
    $objLabel.Location = New-Object System.Drawing.Size(10,20) 
    $objLabel.Size = New-Object System.Drawing.Size(280,20) 
    $objLabel.Text = "Please make a selection from the list below:"
    $objForm.Controls.Add($objLabel) 

    $objListbox = New-Object System.Windows.Forms.Listbox 
    $objListbox.Location = New-Object System.Drawing.Size(10,40) 
    $objListbox.Size = New-Object System.Drawing.Size(260,20) 
    
    #Use this to create a multiselect listbox
    #$objListbox.SelectionMode = "Multisimple"

    [void] $objListbox.Items.Add("MOD")
    [void] $objListbox.Items.Add("M02")
    [void] $objListbox.Items.Add("M03")
    [void] $objListbox.Items.Add("M04")
    [void] $objListbox.Items.Add("ATL")

    $objListbox.Height = 70
    $objForm.Controls.Add($objListbox) 
    $objForm.Topmost = $True
}
    
function Set-Progress{

	# title for the winform
	# $Title = "Directory Usage Analysis: $Path"
	$Title = "BITS Transfer Progress : ($bits.displayname)" # needs work
	#winform dimensions
	$height=100
	$width=400
	# winform background color
	$color = "White"

	# create the form
	$form1 = New-Object System.Windows.Forms.Form
	$form1.Text = $title
	$form1.Height = $height
	$form1.Width = $width
	$form1.BackColor = $color

	$form1.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle 
	# display center screen
	$form1.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen

	# create label
	$label1 = New-Object system.Windows.Forms.Label
	$label1.Text = "not started"
	$label1.Left=5
	$label1.Top= 10
	$label1.Width= $width - 20
	# adjusted height to accommodate progress bar
	$label1.Height=15
	$label1.Font= "Verdana"
	# optional to show border 
	# $label1.BorderStyle=1

	# add the label to the form
	$form1.controls.add($label1)

	$progressBar1 = New-Object System.Windows.Forms.ProgressBar
	$progressBar1.Name = 'progressBar1'
	$progressBar1.Value = 0
	$progressBar1.Style="Continuous"

	$System_Drawing_Size = New-Object System.Drawing.Size
	$System_Drawing_Size.Width = $width - 40
	$System_Drawing_Size.Height = 20
	$progressBar1.Size = $System_Drawing_Size

	$progressBar1.Left = 5
	$progressBar1.Top = 40
	$form1.Controls.Add($progressBar1)
	$form1.Show()| out-null

	# give the form focus
	$form1.Focus() | out-null

	# update the form
	$label1.Text = "Preparing to send files to $bits.displayname" # needs work
	$form1.Refresh()

	start-sleep -Seconds 1

	get-module bitstransfer
	Start-BitsTransfer -Destination \\rdpvm13\transfer\ -Source N:\_rpg.7z -Asynchronous -Credential (Get-Credential) -Priority Normal -RetryTimeout 60 -RetryInterval 120 -DisplayName "AutoTransfer" -Description "Wells Propane"

	$bits = Get-BitsTransfer -Name "AutoTransfer"
	$pct = 0
	while ($bits.JobState -ne "Transferred"  -and $pct -ne 100){
		if ($bits.jobstate -eq "Error" -or $bits.JobState -eq "TransientError" ){
			Resume-BitsTransfer -BitsJob $bits
		}
   
		$pct = ($bits.BytesTransferred / $bits.BytesTotal)*100
		$progressbar1.Value = $pct
		Start-Sleep -Milliseconds 100
		$label1.text="$bits.BytesTransferred Bytes of $bits.BytesTotal Total Transferred" # needs work
		$form1.Refresh()
	}

	$form1.Close()

}

 <#
 # You can use this to dynamically create the listbox from the COIDS.TXT file located in the RPG directory.  
 # Additional changes must be made to the form to be able to use the logic, though.

 function Get-CID ($rpgdir){

    $CID = @()
    $COIDS = get-content "$rpgdir\coids.txt"
    $COIDS = $COIDs -split (';')

    $COIDS | ForEach-Object {
        $CID += $_
    }
 }
 #>

function Copy-CPSList{

	Get-CIDList
    $CIDChoice = @()
    $dir = @("G:\","H:\")
    $RPGDir = join-path -path $dir -ChildPath RPG
    $CTP = "CTPOUTPT.D"
    $RemoteDir = "\\tsclient\c\users\rich\desktop\CTPOutput"
	$date = Get-Date -UFormat %Y-%m-%d
    $error.clear()
        
    $result = $objForm.ShowDialog()
        
    if ($result -eq [System.Windows.Forms.DialogResult]::OK -and $objListbox.SelectedIndex -ge 0){
            
            foreach ($objItem in $objListbox.SelectedItems){
                $cidchoice += $objItem
                $RemoteCIDDir = Join-Path -path $RemoteDir -ChildPath $objitem
                    
                $RemoteCIDDir | ForEach-Object {
                    if (!(Test-Path -Path $_)){
                        md $_
                    }
                }
            }
        }
    if ($cidchoice -eq "MOD" -or "M02" -or "M03" -or "ATL"){

        $ctprpg = join-path -Path $rpgdir[0] -ChildPath $ctp
        Copy-Item -path $ctprpg -destination $remoteciddir\$date + "CTPOUTPT.D" -Force
    } 

    if ($cidchoice -eq "M04"){
            
        $ctprpg = join-path -Path $rpgdir[1] -ChildPath $ctp
        Copy-Item -path $ctprpg -destination $remoteciddir\ -Force
    }
        
    if ($result -eq [System.Windows.Forms.DialogResult]::CANCEL){
        [System.Windows.Forms.MessageBox]::Show("Program was Canceled.")
    }
    if ($error[0] -eq $null){
        [System.Windows.Forms.MessageBox]::Show("$CTP was transferred for Company ID $cidchoice.")
    }
    else{
        [System.Windows.Forms.MessageBox]::Show("$error[0]")
        }

}

Copy-CPSList