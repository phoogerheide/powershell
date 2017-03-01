<#

.DESCRIPTION
    Test-Connection using a txt file with PC names.

#>

Param(
    [string[]]$ComputerList = "C:\test\computers.txt"
)

$computers = Get-Content $ComputerList
$computer_count = $computers.Length

$online = @()
$offline = @()

$i = 0

foreach ($computer in $computers) {
    if (Test-Connection $computer -Count 1 -Quiet)
    {
        $online += $computer
    }
    else
    {
        $offline += $computer
    }
    $progess = [int][Math]::Ceiling(($i / $computer_count) * 100)
    Write-Progress -Activity "Testing $computer" -PercentComplete $progess -Status "$progess% complete"
    $i++
}

Write-Host "`n ONLINE:" -ForegroundColor Green
$online
Write-Host "`n OFFLINE:" -ForegroundColor Red
$offline