$lines = Get-Content 'C:\Users\nguye\Downloads\KiemTraGiuaKy\10.2.0\exam_docx_dump.txt' -Encoding utf8

$parts = @{}
$currentSection = "HEADER"
$countBySection = @{}

foreach ($line in $lines) {
    if ($line -match '^\[PART (\d+)\]') {
        $currentSection = "PART " + $matches[1]
    }
    if ($line -match '^\[PASSAGE_SET') {
        $currentSection = "PASSAGE_SET"
    }
    if ($line -match '^\[Q:\s*(\d+)\]') {
        $q = [int]$matches[1]
        $sec = if ($q -le 130) { "Part 5" } elseif ($q -le 146) { "Part 6" } else { "Part 7" }
        if (-not $countBySection.ContainsKey($sec)) { $countBySection[$sec] = 0 }
        $countBySection[$sec]++
    }
}

Write-Output "Question counts by part:"
$countBySection.GetEnumerator() | ForEach-Object { Write-Output "$($_.Key): $($_.Value) questions" }
