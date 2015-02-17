<#
.Author
	Jonathan Bailey
.Synopsis
   Pulls the Product key hex value from the motherboard, converts it to ASCII, and pipes it to slmgr.vbs for activation.
.DESCRIPTION
   In order to run this script, execution policy must be set to unrestricted.  You must also run this script as an administrator.
   This script pulls the product key from a UEFI/Windows 8 motherboard for use in oem key activation in legacy mode.
   Make sure to Have oa3tool.exe in the same working directory as this script.  It is part of Microsoft ADK.
   Use this script to install 32-bit versions of Windows 8.1 on UEFI OEM machines running in legacy mode.  
   Since activation doesn't occur automatically, manual activation is necessary.
#>

# pull the hex value from motherboard and outputs it to $hexdata
$HexData = .\oa3tool.exe /validate

# Find the hex value that contains the product key and formats/trims it for conversion.
$HexData = $HexData | select -First 33 | select -Last 4
$HexData = $HexData -replace '\s+', ' '
$HexData = $HexData.trimstart(' ')
$HexData = $HexData.trimend(' ')

# Split hex values into objects and convert them to decimal, then decimal to ASCII, 
# then set the new value as $prodkey.
$HexData.split(" ") | FOREACH {[CHAR][BYTE]([CONVERT]::toint16($_,16))} | Set-Variable -name prodkey -PassThru

# join the ascii array into a string
$prodkey = $prodkey -join ''
# regex replace all unprintable characters.
$prodkey = $prodkey -replace "[^ -x7e]",""

write-host
write-host success!

# use slmgr.vbs for activation.
slmgr /ipk $prodkey