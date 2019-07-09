$increase = 74578345789
Exit-PSHostProcess

$busy0 = 0
$busy0count = 0
$free0 = 0
$free0count = 0
Get-Content $args[0] | ForEach-Object {
    if ($_ -match '([^ ]+) - \(busy\)') {
        $asDecimal = [System.Convert]::ToInt64($matches[1], 16)
        $busy0 += $asDecimal
        $busy0count ++
        if ($asDecimal -gt 10000) {
            Write-Host busy $asDecimal
        }
    }
    elseif ($_ -match '([^ ]+) - \(free\)') {
        $asDecimal = [System.Convert]::ToInt64($matches[1], 16)
        $free0 += $asDecimal
        $free0count ++;
        if ($asDecimal -gt 10000) {
            Write-Host free $asDecimal
        }
    }
}

$busy1 = 0
$busy1count = 0
$free1 = 0
$free1count = 0
Get-Content $args[1] | ForEach-Object {
    if ($_ -match '([^ ]+) - \(busy\)') {
        $asDecimal = [System.Convert]::ToInt64($matches[1], 16)
        $busy1 += $asDecimal
        $busy1count ++
        if ($asDecimal -gt 10000) {
            Write-Host busy $asDecimal
        }
    }
    elseif ($_ -match '([^ ]+) - \(free\)') {
        $asDecimal = [System.Convert]::ToInt64($matches[1], 16)
        $free1 += $asDecimal
        $free1count ++;
        if ($asDecimal -gt 10000) {
            Write-Host free $asDecimal
        }
    }
}
Write-Host 1.dmp busy `#$busy0count, $busy0, free `#$free0count, $free0
Write-Host 2.dmp busy `#$busy1count, $busy1, free `#$free1count, $free1
$diffBusyCount = $busy1count-$busy0count
$diffBusy = $busy1 - $busy0
$diffFreeCount = $free1count - $free0count
$diffFree = $free1-$free0

Write-Host Summe busy `#$diffBusyCount, $diffBusy, free `#$diffFreeCount, $diffFree

$increase = $diffBusy + $diffFree
Write-Host ("Total {0}, {1} MB" -f $increase, ($increase / (1024 * 1024)))