Add-Type -assembly System.Windows.Forms

#title for the winform
$Title = "BITS Transfer Progress"
#winform dimensions
$height=100
$width=400
#winform background color
$color = "White"

#create the form
$form1 = New-Object System.Windows.Forms.Form
$form1.Text = $title
$form1.Height = $height
$form1.Width = $width
$form1.BackColor = $color

$form1.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle 
#display center screen
$form1.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen

# create label
$label1 = New-Object system.Windows.Forms.Label
$label1.Text = "not started"
$label1.Left=5
$label1.Top= 10
$label1.Width= $width - 20
#adjusted height to accommodate progress bar
$label1.Height=15
$label1.Font= "Verdana"
#optional to show border 
#$label1.BorderStyle=1

#add the label to the form
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

#give the form focus
$form1.Focus() | out-null

#update the form
$label1.Text = "Preparing to send files"
$form1.Refresh()

start-sleep -Seconds 1

get-module bitstransfer
Start-BitsTransfer -Destination \\rdpvm8\transfer\ -Source N:\_rpg.7z -Asynchronous -Credential (Get-Credential) -Priority Normal -RetryTimeout 60 -RetryInterval 120 -DisplayName "AutoTransfer" -Description "Wells Propane"

$bits = Get-BitsTransfer -Name "AutoTransfer"
$pct = 0
while ($bits.JobState -ne "Transferred"  -and $pct -ne 100){
    if ($bits.jobstate -eq "Error" -or $bits.JobState -eq "TransientError" ){
        Resume-BitsTransfer -BitsJob $bits
    }
   
    $pct = ($bits.BytesTransferred / $bits.BytesTotal)*100
    $progressbar1.Value = $pct
    Start-Sleep -Milliseconds 100
    $label1.text="Sending files..."
    $form1.Refresh()
}

$form1.Close()