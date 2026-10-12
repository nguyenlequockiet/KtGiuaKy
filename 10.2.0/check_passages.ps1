$lines = Get-Content 'C:\Users\nguye\Downloads\KiemTraGiuaKy\10.2.0\exam_docx_dump.txt' -Encoding utf8
$passages = @()
foreach ($line in $lines) {
    if ($line -match '^\[PASSAGE_SET:\s*([^\]]+)\]') {
        $passages += $matches[1]
    }
}
Write-Output ("Total passages: " + $passages.Count)
$passages | ForEach-Object { Write-Output $_ }
