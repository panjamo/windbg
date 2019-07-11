@echo off
REM https://ss64.com/nt/syntax-args.html
REM https://ss64.com/nt/for.html
cd heaps
setlocal EnableDelayedExpansion 
REM convert hex to decimal
FOR /F "tokens=*" %%G IN ('dir /b /s /AD') DO (
    FOR /F "tokens=*" %%H IN ('hex2dec -nobanner 0x%%~nG') DO (
        echo rename %%~nG "%%H"
        rename %%~nG "%%H"
    )
)

FOR /F "tokens=*" %%G IN ('dir /b /s /AD') DO (
    Pushd "%%G"
    FOR %%H IN (*) DO (
        mkdir "%%G-%%~zH"
        move "%%H" "%%G-%%~zH"
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
