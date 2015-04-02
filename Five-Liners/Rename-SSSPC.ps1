Function Rename-SSSPC{
    <#
    .AUTHOR
        Jonathan Baily and Tyler Brown
    .SYNOPSIS 
       Renames a computer. 
    .DESCRIPTION
       Renames the computer by grabing the serial number off the motherboard and replacing the current computer name.
    .EXAMPLE
       Rename-SSSPC
    .INPUTS
       No inputs required.  This CMDlet pulls information from the motherboard of the PC.
    .OUTPUTS
       No outputs.  The data is automatically piped to the Rename-Computer CMDlet.
    .NOTES
       This CMDlet requires no parameters.  This CMDlet only runs on PowerShell 4.0.
    .COMPONENT
       This CMDlet belongs to the SSSCMDlets Module.
    #>
    CMDletbinding[( DefaultParameterSetName ='Static', 
                    SupportsShouldProcess=$true, 
                    PositionalBinding=$false
                 )]
    BEGIN {}
    PROCESS {
        $serial = gcim win32_bios | select -Property serialnumber | ft -HideTableHeaders
        $serial = $serial | out-string
        $serial = $serial.trim( )
        Rename-Computer -ComputerName (gcim win32_operatingsystem).CSName -NewName $serial
    }
    END{}
}