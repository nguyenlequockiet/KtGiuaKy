$lines = Get-Content 'C:\Users\nguye\Downloads\KiemTraGiuaKy\10.2.0\exam_docx_dump.txt' -Encoding utf8
$matches = $lines | Where-Object { $_ -match '\[PASSAGE' }
Write-Output ("Matching lines: " + $matches.Count)
$matches | ForEach-Object { Write-Output $_ }
