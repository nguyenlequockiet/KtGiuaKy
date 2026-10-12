$lines = Get-Content 'C:\Users\nguye\Downloads\KiemTraGiuaKy\10.2.0\exam_docx_dump.txt' -Encoding utf8
for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -match '147-148') {
        $lines[($i-2)..($i+25)] | ForEach-Object { Write-Output $_ }
        break
    }
}
