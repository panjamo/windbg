SET PATH=C:\Program Files\Git\usr\bin;%PATH%
SET PATH=c:\Program Files (x86)\Windows Kits\10\Debuggers\x64;%PATH%
rmdir /s /q heaps
mkdir heaps

if not exist %1.AllHeaps.txt cdb.exe -z %1 -c "!heap -p -all;q" > %1.AllHeaps.txt
if not exist %2.AllHeaps.txt cdb.exe -z %2 -c "!heap -p -all;q" > %2.AllHeaps.txt

sed "s/\*.*/ /" %1.AllHeaps.txt | awk  "/(busy)/ { print \".logopen heaps/\" $6 \"/\" $1 \";!heap -p -a \" $1 \";? \" $6}" > %1.Adresses.txt
sed "s/\*.*/ /" %2.AllHeaps.txt | awk  "/(busy)/ { print \".logopen heaps/\" $6 \"/\" $1 \";!heap -p -a \" $1 \";? \" $6}" > %2.Adresses.txt

cat %1.Adresses.txt > AllAdresses.txt
cat %2.Adresses.txt >> AllAdresses.txt
sort AllAdresses.txt | uniq --count | grep  "2 ." | sed "s/      2 //" > double.txt

cat %2.Adresses.txt > %2.AdressesWithDouble.txt
cat double.txt >> %2.AdressesWithDouble.txt
sort %2.AdressesWithDouble.txt | uniq --count | grep  "1 ." | sed "s/      1 //" > %2.AdressesSortedDiff.txt


echo count, total bytes, bytes, hex size (decimal size) > %2.Summary.txt

sort %2.AdressesWithDouble.txt | uniq --count | grep  "1 ." | sed "s/      1 //" | awk --non-decimal-data "/ / { print $6 \" \" (\"0x\"$6)+0   }" | sort | uniq --count | sort | awk "{ hexlen=\"0x\"$2 ; sum=sum+$1*$3 ;  printf \"%%10s%%15d%%10d%%10s (%%s)\n\", $1, sum, $1*$3, hexlen, $3 }" >> %2.Summary.txt

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

for %%x in (split*) do echo q >> "%%x"
for %%x in (split*) do start /min /low cdb.exe -z %2 -c "$<%%x"

del cdbInput.txt
