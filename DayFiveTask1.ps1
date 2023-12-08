function Parse-MapSection
{
    param(
        [string]$sectionData
    )

    $map = @()
    $lines = $sectionData -split "\r?\n"
    foreach ($line in $lines)
    {
        if ($line -match '(\d+) (\d+) (\d+)')
        {
            $map += $Matches[0]
        }
    }
    return $map
}

# Convert-Number Function updated to use Int64
function Convert-Number
{
    param([Int64]$number, $map)
    foreach ($line in $map)
    {
        $parts = $line -split ' '
        $destStart = [Int64]$parts[0]
        $sourceStart = [Int64]$parts[1]
        $rangeLength = [Int64]$parts[2]

        if ($number -ge $sourceStart -and $number -lt ($sourceStart + $rangeLength))
        {
            return $destStart + ($number - $sourceStart)
        }
    }
    return $number
}

$sessionToken = '53616c7465645f5fffe36a9b0da02fa1ef63bea9d399a1fdc2026e9dd076314bd939e99af30453abfa2c614fec8a1da391160550cd6369c970e99a1c73277dc9'
$url = 'https://adventofcode.com/2023/day/5/input'

$headers = @{
    "Cookie" = "session=$sessionToken"
}
$response = Invoke-WebRequest -Uri $url -Headers $headers
$inputData = $response.Content

# Parse Seeds
$seedsSection = $inputData -match 'seeds: (.*)' | Out-Null
$seeds = $Matches[1] -split ' ' | ForEach-Object { [Int64]$_ }

$sections = $inputData -split 'map:'
$seedToSoilMap = Parse-MapSection -sectionData $sections[1]
$soilToFertilizerMap = Parse-MapSection -sectionData $sections[2]
$fertilizerToWaterMap = Parse-MapSection -sectionData $sections[3]
$waterToLightMap = Parse-MapSection -sectionData $sections[4]
$lightToTemperatureMap = Parse-MapSection -sectionData $sections[5]
$temperatureToHumidityMap = Parse-MapSection -sectionData $sections[6]
$humidityToLocationMap = Parse-MapSection -sectionData $sections[7]

# Process the seeds through the mappings
$locations = @()
foreach ($seed in $seeds)
{
    $currentValue = $seed
    $currentValue = Convert-Number -number $currentValue -map $seedToSoilMap
    $currentValue = Convert-Number -number $currentValue -map $soilToFertilizerMap
    $currentValue = Convert-Number -number $currentValue -map $fertilizerToWaterMap
    $currentValue = Convert-Number -number $currentValue -map $waterToLightMap
    $currentValue = Convert-Number -number $currentValue -map $lightToTemperatureMap
    $currentValue = Convert-Number -number $currentValue -map $temperatureToHumidityMap
    $currentValue = Convert-Number -number $currentValue -map $humidityToLocationMap

    $locations += $currentValue
}

# Find the lowest location number
$lowestLocation = ($locations | Sort-Object)[0]
Write-Output "The lowest location number is $lowestLocation"