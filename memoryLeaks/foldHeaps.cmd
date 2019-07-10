@echo off
REM https://ss64.com/nt/syntax-args.html
REM https://ss64.com/nt/for.html
cd heaps
setlocal EnableDelayedExpansion 
FOR /F "tokens=*" %%G IN ('dir /b /s /AD') DO (
    Pushd %%G
    FOR %%H IN (*) DO (
        mkdir "%%G-%%~zH"
        move "%%H" "%%G-%%~zH"
    )
    Popd
    rmdir %%G
)
SET WC=0
FOR /F "tokens=*" %%G IN ('dir /b /s /AD') DO (
    Pushd %%G
    FOR /F "tokens=*" %%H IN ('ls ^| wc -l') DO (
        SET WC=%%H
    )
    Popd
    echo rename %%~nG %%~nG-!WC!
    rename %%~nG %%~nG-!WC!
)
exit /b
