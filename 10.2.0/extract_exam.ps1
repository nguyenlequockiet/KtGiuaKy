Add-Type -AssemblyName System.IO.Compression.FileSystem

$tempZip = 'c:\Users\nguye\Downloads\KiemTraGiuaKy\10.2.0\temp_exam.zip'
# Copy using file stream with ReadWrite share
$srcStream = [System.IO.File]::Open('C:\Users\nguye\Downloads\EXAM.docx', [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite)
$dstStream = [System.IO.File]::Create($tempZip)
$srcStream.CopyTo($dstStream)
$srcStream.Close()
$dstStream.Close()

$zip = [System.IO.Compression.ZipFile]::OpenRead($tempZip)
$entry = $zip.GetEntry('word/document.xml')
$stream = $entry.Open()
$reader = New-Object System.IO.StreamReader($stream, [System.Text.Encoding]::UTF8)
$xmlContent = $reader.ReadToEnd()
$reader.Close()
$stream.Close()
$zip.Dispose()

# Extract paragraph text
$regex = '<w:p\b[^>]*>(.*?)</w:p>'
$pMatches = [regex]::Matches($xmlContent, $regex, [System.Text.RegularExpressions.RegexOptions]::Singleline)

$lines = @()
foreach ($m in $pMatches) {
    $pXml = $m.Groups[1].Value
    $tMatches = [regex]::Matches($pXml, '<w:t\b[^>]*>(.*?)</w:t>', [System.Text.RegularExpressions.RegexOptions]::Singleline)
    $pText = ($tMatches | ForEach-Object { $_.Groups[1].Value }) -join ''
    if ($pText.Trim().Length -gt 0) {
        $lines += $pText.Trim()
    }
}

Write-Output ("Total non-empty paragraphs: " + $lines.Count)
$lines | Select-Object -First 50 | ForEach-Object { Write-Output $_ }
$outputFile = 'C:\Users\nguye\Downloads\KiemTraGiuaKy\10.2.0\exam_docx_dump.txt'
$lines | Out-File -FilePath $outputFile -Encoding utf8
Write-Output ("Saved all lines to " + $outputFile)
