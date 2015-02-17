$sig = @'
[DllImport("User32.dll")]
public static extern int GetGuiResources(IntPtr hProcess, int uiFlags);
'@
 
Add-Type -MemberDefinition $sig -name NativeMethods -namespace Win32
$gdiarray = @()
$processes = [System.Diagnostics.Process]::GetProcesses()
[int]$gdiHandleCount = 0
ForEach ($p in $processes){

    $gdi = New-Object -TypeName System.Object
    [int]$gdiHandles = [Win32.NativeMethods]::GetGuiResources($p.Handle, 0)
    $gdiHandleCount += $gdiHandles
    $gdi | Add-Member -MemberType NoteProperty -Name "ProcName" -Value "$($p.Name)"
    $gdi | Add-Member -MemberType NoteProperty -Name "GDIProc" -Value $([int]$gdiHandles)
    $gdi | Add-Member -MemberType NoteProperty -Name "PID" -Value "$($p.id)"
    $gdi | Add-Member -MemberType NoteProperty -Name "Start" -Value "$($p.starttime)"
    $gdi | Add-Member -MemberType NoteProperty -Name "Session" -Value "$($p.sessionid)"
    $gdiarray += $gdi
}

#Set-Location d:\
$log = $gdiarray | sort -Property gdiproc -Descending | ft -AutoSize
$date = get-date -UFormat %m-%d-%y
$filename = $date+"GDIlog.txt"
$log = $log | out-string
$log = $log + "Total number of GDI handles " + $gdiHandleCount.ToString() | Set-Content $filename