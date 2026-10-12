$lines = Get-Content 'C:\Users\nguye\Downloads\KiemTraGiuaKy\10.2.0\exam_docx_dump.txt' -Encoding utf8
for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -match '\[Q:\s*131\]') {
        $lines[($i-5)..($i+35)] | ForEach-Object { Write-Output $_ }
        break
    }
}
