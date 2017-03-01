<#

### bibliotheek-webcrawler.ps1 ###

.DESCRIPTION
    Webcrawler for public library website, with the purpose of generating a whitelist file for kiosk systems.

.AUTHOR
    P Hoogerheide

.NOTES
    Change the $whitelistFile variable to an existing folder before running.

#>

param(
    [string]$whitelistFile = "C:\test\whitelist.txt"
)
 
function crawl(){
    param(
        [string]$site,
        [int]$count
    )
    Write-Progress -Activity $site -Status "Progress: $count URLs remaining"
    $result = Invoke-WebRequest $site
    $output = $result.AllElements | Where target -eq "_blank" | Select * -ExpandProperty href
    $page = $result.AllElements | where title -Match '[2-9]{1}' | Select * -ExpandProperty href -Unique | sls 'pageNr'
    $weblink = $output | Select-String -Pattern '(http)|(www)'
    echo $weblink >> $whitelistFile
    checkpage $page
}
 
function checkpage(){
    param(
        [array]$pages
    )
    for ($i = 2; $i -lt 10; $i++){
        if($pages -like "/Collectie/IBibliotheek-online-databanken/Categorie/*.htm?pageNr=$i"){
            Write-Progress -Activity "$site`?pageNr=$i" -Status "-Processing pageNr: $i"
            $result = Invoke-WebRequest "$site`?pageNr=$i"
            $output = $result.AllElements | Where target -eq "_blank" | Select * -ExpandProperty href
            $weblink = $output | Select-String -Pattern '(http)|(www)'
            echo $weblink >> $whitelistFile
        }
    }
}
 
function startcrawl(){
    param(
        [string]$URL = "http://www.bibliotheekdenhaag.nl/Collectie/IBibliotheek-online-databanken.htm"
    )
    $result = Invoke-WebRequest $URL
    $output = $result.Links | Where Class -eq "navigation" | Select * -ExpandProperty href
    $databanken = $output | Select-String Categorie
    return $databanken
}
 
function cleantxt(){
    param(
        [string]$file
    )
    (gc $file) | ? {$_.trim() -ne "" } | Set-Content $file
    $hosts = Get-Content $file
    $hosts | %{$url = New-Object System.Uri $_;$url.Host -replace "www.","" } | select -Unique | Set-Content $file;
    (gc $file) | %{"*$_/" } | Set-Content $file
}
 
echo "" > $whitelistFile
$databanken = startcrawl
$counter = $databanken.Count
 
foreach($link in $databanken){
    $url = "http://www.bibliotheekdenhaag.nl$link"
    crawl $url $counter
    $counter--
}
 
cleantxt $whitelistFile