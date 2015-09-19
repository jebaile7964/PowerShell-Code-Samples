Function Remove-SSSCheckpoints{
    Param( [ValidateSet('All','RDP','SQL','DC','SSS')]
           $VMScope )
    BEGIN{}
    PROCESS{
        switch ($VMScope){
            ALL { $VMs = Get-VM }
            RDP { $VMs = Get-VM | Where-Object name -Match 'RDP' }
            SQL { $VMs = Get-VM | Where-Object name -Match 'SQL' }
            DC { $VMs = Get-VM | Where-Object name -Match 'DC' }
            SSS { $Vms = Get-VM | Where-Object name -Match 'SSS' }
        }
    }
    END{
        $VMs | Get-VMSnapshot | Remove-VMSnapshot
    }
}

Function Get-SSSVMExports{
    Param( [ValidateSet('All','RDP','SQL','DC','SSS')]
           $VMScope,
           $Path )
    BEGIN{
        switch($VMScope){
            ALL {$VMs = Get-VM}
            RPD { $VMs = Get-VM | Where-Object name -Match 'RDP' }
            SQL { $VMs = get-vm | where-object name -Match 'SQL' }
            DC { $VMs = get-vm | Where-Object name -Match 'DC' }
            SSS { $VMs = get-vm | where-object name -Match 'SSS' }
        } 
        $i = 0
    }
    PROCESS{
        $VmExport = Export-VM -ComputerName $VMs -Path $Path
        
        foreach ($v in $VMS){
            $i++
            Write-Progress -Activity "Exporting $($v.name)..." ` -Status "$i of $($vms.count) Completed" `
                -PercentComplete "(($i / $($vms.count)) * 100)"
        }
    }
    END{
        write-output $result
    }
}

New-SssRdpVmConfig{
    Param( $Name,
           $SwitchName,
           $VhdPath,
           $Path )
    BEGIN{}
    PROCESS{
        New-VM -Name $Name -MemoryStartupBytes 2048 -BootDevice VHD -SwitchName $SwitchName -VHDPath $VhdPath -Path $Path -Generation 1
        Set-VM -Name $Name -ProcessorCount 4 -DynamicMemory $true -MemoryMinimumBytes 2048
        Enable-VMIntegrationService -VMName $Name
    }
    END{
    $Result = get-vm -Name $Name
    Write-Output $Result
    }
}

New-SssRdpVmVhd{}

New-SssRdpWindowsInstall{}

