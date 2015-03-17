
Function install-mappoint{
    BEGIN{
        $test = Get-WmiObject -Class win32_product | Where-Object {
            $_.name -eq "Microsoft Mappoint North America 2006"
        }
    }
    PROCESS{
        if ( $test.name -ne "Microsoft Mappoint North America 2006"){
            msiexec /i q:\map2006\mappoint\msmap\data.msi /qn /norestart /le c:\mappointlog.txt OFFICE_INTEGRATION=0
        }
    }
    END{
        Remove-Variable $test
    }
}