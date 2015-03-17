    get-module bitstransfer
    Start-BitsTransfer -Destination \\pathto\transfer -Source d:\files*.* -Asynchronous -Credential (Get-Credential) -Priority  -RetryTimeout 60 -RetryInterval 120

    $bits = Get-BitsTransfer -Name "BITS Transfer"

    while ($bits.JobState -eq "Transferring" -or $bits.JobState -eq "TransientError" -or $bits.JobState -eq "Connecting" -or $bits.jobstate -eq "Error"  -and $pct -ne 100){
        if ($bits.jobstate -eq "Error"){
            Resume-BitsTransfer -BitsJob $bits
        }
   
        $pct = ($bits.BytesTransferred / $bits.BytesTotal)*100
        Write-Host "Percent complete: $pct" 
        Start-Sleep 5
    }