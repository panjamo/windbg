@echo off
echo usage: foldHeaps [-fast]
REM pause
REM https://ss64.com/nt/syntax-args.html
REM https://ss64.com/nt/for.html

del split_?? 2> nul > nul

IF EXIST "split_aa" (
    echo The debuggers instances [CDB] are running, wait until they terminate.
    echo Then start this script again.
    pause
    exit /b
)

IF EXIST "heaps.7z" (
    rmdir /s /q heaps
    mkdir heaps
    pushd heaps
    7z x ../heaps.7z
    popd
) ELSE (
    pushd heaps
    7z a -mx=1 -r ../heaps *
    popd
    git add heaps.7z
    git commit -m "foldheaps %1 (packed raw data added)"
)

pushd heaps
setlocal EnableDelayedExpansion 

REM convert hex to decimal
echo.
echo rename folders 
FOR /F "tokens=*" %%G IN ('dir /b /s /AD') DO (
    FOR /F "tokens=*" %%H IN ('hex2dec -nobanner 0x%%~nG') DO (
        echo | set /p="."
        rename "%%~nG" "%%H"
    )
)

echo.
echo move files 
FOR /F "tokens=*" %%G IN ('dir /b /s /AD') DO (
    pushd "%%G"
    FOR %%H IN (*) DO (
        REM FileSize
        if [%1] == [-fast] (
            echo | set /p="."
            mkdir "%%G-%%~zH" 2> nul
            move "%%H" "%%G-%%~zH"  > nul          
        ) ELSE (
            REM CHECKSUM
            FOR /F "tokens=*" %%C IN ('tail -n +6 %%H ^| head -n -6 ^| cksum ^| awk "{ print $1 }"') DO (
                echo | set /p="."
                mkdir "%%G-%%C" 2> nul
                move "%%H" "%%G-%%C" > nul
            )
        )
    )
    popd
    rmdir "%%G"
)


SETLOCAL ENABLEEXTENSIONS 

echo.
echo rename folders again
SET WC=0
FOR /F "tokens=*" %%G IN ('dir /b /s /AD') DO (
    pushd "%%G"
    FOR /F "tokens=*" %%H IN ('ls ^| wc -l') DO (
        SET WC=00000000000000%%H
    )

    REM delete all files exept
    if NOT [%1] == [-fast] (
        FOR /F "tokens=*" %%H IN ('dir /b /A-D ^| tail -n +2') DO (
            del %%H
        )
        FOR /F "tokens=*" %%H IN ('dir /b /A-D') DO (
            move %%H "..\#!WC:~-6! - %%~nG.txt" > nul
            popd
            rmdir "%%G"
        )
    ) ELSE (
        ren * *.txt
        popd    
        rename "%%~nG" "#!WC:~-5! - %%~nG"
    )
    echo | set /p="."    
)
endlocal
endlocal
REM explorer .
popd
git add -A .
git commit -m "foldheaps %1 (results added)"

