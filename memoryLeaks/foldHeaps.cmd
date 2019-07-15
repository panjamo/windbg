@echo off
REM https://ss64.com/nt/syntax-args.html
REM https://ss64.com/nt/for.html
pushd heaps
setlocal EnableDelayedExpansion 
convert hex to decimal
FOR /F "tokens=*" %%G IN ('dir /b /s /AD') DO (
    FOR /F "tokens=*" %%H IN ('hex2dec -nobanner 0x%%~nG') DO (
        echo rename %%~nG "%%H"
        rename %%~nG "%%H"
    )
)

FOR /F "tokens=*" %%G IN ('dir /b /s /AD') DO (
    Pushd "%%G"
    FOR %%H IN (*) DO (
        REM FileSize
        REM mkdir "%%G-%%~zH"
        REM move "%%H" "%%G-%%~zH"

        REM CHECKSUM
        FOR /F "tokens=*" %%C IN ('tail -n +6 %%H ^| head -n -6 ^| cksum ^| awk "{ print $1 }"') DO (
            mkdir "%%G-%%C" 2> nul
            move "%%H" "%%G-%%C"
        )
    )
    Popd
    rmdir "%%G"
)

SET WC=0
FOR /F "tokens=*" %%G IN ('dir /b /s /AD') DO (
    Pushd "%%G"
    FOR /F "tokens=*" %%H IN ('ls ^| wc -l') DO (
        SET WC=%%H
    )
    Popd
    echo rename "%%~nG" "%%~nG-!WC!"
    rename "%%~nG" "%%~nG-!WC!"
)
exit /b
