@ECHO OFF
SET PATH=C:\Program Files\Git\usr\bin;%PATH%
SET PATH=c:\Program Files (x86)\Windows Kits\10\Debuggers\x64;%PATH%
rmdir /s /q heaps  2> nul
mkdir heaps  2> nul

REM set MYTIME=%time::=_%
REM move heaps.7z "heaps_%MYTIME: =0%.7z" 2> nul

git init 
echo execute '!heap -p -all' on %1...
if not exist %1.AllHeaps.txt cdb.exe -z %1 -c "!heap -p -all;q" > %1.AllHeaps.txt
git add %1.AllHeaps.txt
echo execute '!heap -p -all' on %2...
if not exist %2.AllHeaps.txt cdb.exe -z %2 -c "!heap -p -all;q" > %2.AllHeaps.txt
git add %2.AllHeaps.txt

sed "s/\*.*/ /" %1.AllHeaps.txt | awk  "/(busy)/ { print \".logopen heaps/\" $6 \"/\" $1 \";!heap -p -a \" $1 \";? \" $6}" > %1.Adresses.txt
sed "s/\*.*/ /" %2.AllHeaps.txt | awk  "/(busy)/ { print \".logopen heaps/\" $6 \"/\" $1 \";!heap -p -a \" $1 \";? \" $6}" > %2.Adresses.txt

cat %1.Adresses.txt > AllAdresses.txt
cat %2.Adresses.txt >> AllAdresses.txt
sort AllAdresses.txt | uniq --count | grep  "2 ." | sed "s/      2 //" > double.txt

cat %2.Adresses.txt > %2.AdressesWithDouble.txt
cat double.txt >> %2.AdressesWithDouble.txt
sort %2.AdressesWithDouble.txt | uniq --count | grep  "1 ." | sed "s/      1 //" > %2.AdressesSortedDiff.txt

"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "$env:PATH+=';' + $pwd ; BusyFree.ps1 .\%1.AllHeaps.txt .\%2.AllHeaps.txt" > %2.Summary.txt

echo count, total bytes, bytes, hex size (decimal size) >> %2.Summary.txt

sort %2.AdressesWithDouble.txt | uniq --count | grep  "1 ." | sed "s/      1 //" | awk --non-decimal-data "/ / { print $6 \" \" (\"0x\"$6)+0   }" | sort | uniq --count | sort -n -r | awk "{ hexlen=\"0x\"$2 ; sum=sum+$1*$3 ;  printf \"%%10s%%15d%%10d%%10s (%%s)\n\", $1, sum, $1*$3, hexlen, $3 }" >> %2.Summary.txt
git add %2.Summary.txt
start notepad %2.Summary.txt

git commit -m "compareDumps %~1 %~2"
REM cat %1.Adresses.txt > %1.AdressesWithDouble.txt
REM cat double.txt >> %1.AdressesWithDouble.txt
REM sort %1.AdressesWithDouble.txt | uniq --count | grep  "1 ." | sed "s/      1 //" | awk --non-decimal-data "/ / { print $6 \" \" (\"0x\"$6)+0   }" | sort | uniq --count | sort | awk "{ hexlen=\"0x\"$2 ; printf \"%%10s%%10d%%10s (%%s)\n\", $1, $1*$3, hexlen, $3 }" > %1.AdressesSortedDiffUniq.txt

awk "/ / { print \"heaps/\" $6 }" < %2.AdressesSortedDiff.txt | uniq | xargs -n1 mkdir

shuf < %2.AdressesSortedDiff.txt > cdbInput.txt

del AllAdresses.txt
del double.txt
del *WithDouble.txt
del *AdressesSortedDiff.txt
del *Adresses.txt

wc -l cdbInput.txt  | awk "{ lines=int($1/4) + 1 ; print lines }" | xargs -I$ split -l "$" cdbInput.txt split_

for %%x in (split*) do echo .logclose >> "%%x"
for %%x in (split*) do echo q >> "%%x"
for %%x in (split*) do start /min /low cdb.exe -z %2 -c "$<%%x"

del cdbInput.txt

echo wait until CDB's are ready (check if split_aa file can be deleted)
:still_more_files
    echo | set /p="."    
    ping -n 10 127.0.0.1 >nul
    rm split_aa 2> nul
    REM echo ERRORLEVEL = %ERRORLEVEL% 
    if [%ERRORLEVEL%] == [1] (
        goto :still_more_files
    )

REM start foldheaps 
ping -n 5 127.0.0.1 >nul
foldheaps.cmd
