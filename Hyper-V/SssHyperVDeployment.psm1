Function Remove-SSSCheckpoints{
    Param( [ValidateSet('All','RDP','SQL','DC','SSS')]
           $VMScope )
    BEGIN{}
    PROCESS{
        If ($VMScope -eq 'All'){
            $VMs = get-vm
        }
        If($VMScope -eq 'RDP'){
            $VMs = get-vm | where-object name -Match 'RDP'
        }
        If($VMScope -eq 'SQL'){
            $VMs = get-vm | Where-Object name -Match 'SQL'
        }
        if($VMScope -eq 'DC'){
            $VMs = Get-vm | Where-Object name -Match 'DC'
        } 
        if($VMScope -eq 'SSS'){
            $VMs = Get-vm | Where-Object name -Match 'SSS'
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
        If ($VMScope -eq 'All'){
            $VMs = get-vm
        }
        If($VMScope -eq 'RDP'){
            $VMs = get-vm | where-object name -Match 'RDP'
        }
        If($VMScope -eq 'SQL'){
            $VMs = get-vm | Where-Object name -Match 'SQL'
        }
        if($VMScope -eq 'DC'){
            $VMs = Get-vm | Where-Object name -Match 'DC'
        } 
        if($VMScope -eq 'SSS'){
            $VMs = Get-vm | Where-Object name -Match 'SSS'
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
    END{}
}

New-SssRdpVmVhd{}

New-SssRdpWindowsInstall{}

