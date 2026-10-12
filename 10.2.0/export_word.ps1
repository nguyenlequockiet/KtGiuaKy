Add-Type -AssemblyName System.IO.Compression.FileSystem

$dumpFile = 'C:\Users\nguye\Downloads\KiemTraGiuaKy\10.2.0\exam_docx_dump.txt'
$lines = Get-Content $dumpFile -Encoding utf8

# Helper to escape XML special chars
function Escape-XmlText($text) {
    if ($null -eq $text) { return "" }
    $s = $text -replace '&', '&amp;' -replace '<', '&lt;' -replace '>', '&gt;' -replace '"', '&quot;' -replace "'", '&apos;'
    $s = $s -replace '\[cite:\s*\d+\]', ''
    return $s.Trim()
}

# Collect formatted document lines
$docLines = @()

$docLines += "[EXAM_CODE]: ETS_2024_RC_TEST_06"
$docLines += "[EXAM_TITLE]: ETS TOEIC Reading 2024 - Test 06"
$docLines += "[DURATION]: 75"
$docLines += "[TOTAL_QUESTIONS]: 100"
$docLines += "[CATEGORY]: Full Reading"
$docLines += "[DIFFICULTY]: Tiêu chuẩn ETS"
$docLines += ""

$currentQ = 0
$inHeader = $true

for ($i = 0; $i -lt $lines.Count; $i++) {
    $line = $lines[$i].Trim()
    if ($line.Length -eq 0) { continue }

    # Skip old header lines since we wrote new ones
    if ($line -match '^\[EXAM_' -or $line -match '^\[DURATION\]' -or $line -match '^\[TOTAL_QUESTIONS\]' -or $line -match '^\[CATEGORY\]' -or $line -match '^\[DIFFICULTY\]') {
        continue
    }

    if ($line -match '^\[PART') {
        $docLines += ""
        $docLines += "=========================================================="
        $docLines += $line
        $docLines += "=========================================================="
        $docLines += ""
        continue
    }

    if ($line -match '^\[PASSAGE_SET') {
        $docLines += ""
        $docLines += "----------------------------------------------------------"
        $docLines += $line
        continue
    }

    if ($line -match '^\[Q:\s*(\d+)\]') {
        $currentQ = [int]$matches[1]
        $docLines += ""
        $docLines += $line

        # If it's Part 6 (131 - 146), ensure PROMPT is added right after [Q: xxx]
        if ($currentQ -ge 131 -and $currentQ -le 146) {
            $docLines += "[PROMPT]: Chọn từ hoặc câu thích hợp nhất để điền vào vị trí [$currentQ] trong đoạn văn trên."
        }
        continue
    }

    if ($line -match '^\[KEY\]:\s*([A-D])') {
        $docLines += $line
        # If Category was missing in Part 6 or Part 7, ensure it's written
        if ($currentQ -ge 131 -and $currentQ -le 146) {
            $docLines += "[CATEGORY]: Điền từ vào đoạn văn (Text Completion - Part 6)"
        } elseif ($currentQ -ge 147 -and $currentQ -le 200) {
            $docLines += "[CATEGORY]: Đọc hiểu văn bản (Reading Comprehension - Part 7)"
        }
        continue
    }

    # Clean citations like [cite: 4]
    $cleaned = $line -replace '\[cite:\s*\d+\]', ''
    $docLines += $cleaned.Trim()
}

# Write clean text version
$outTxtPath = 'C:\Users\nguye\Downloads\ETS_TOEIC_2024_Test_06_Chuan.txt'
$docLines | Out-File -FilePath $outTxtPath -Encoding utf8
Write-Output ("Saved clean text to: " + $outTxtPath)

# Build XML paragraphs
$sb = New-Object System.Text.StringBuilder
[void]$sb.AppendLine('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>')
[void]$sb.AppendLine('<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">')
[void]$sb.AppendLine('  <w:body>')

foreach ($line in $docLines) {
    $esc = Escape-XmlText $line
    $isHeader = $line -match '^\[PART' -or $line -match '^\[PASSAGE_SET' -or $line -match '^\[Q:'
    $isTag = $line -match '^\[(PROMPT|KEY|EXAM_|DURATION|CATEGORY|EXPLANATION|DOC_)'
    $isSep = $line -match '^(=|-){10,}'

    [void]$sb.AppendLine('    <w:p>')
    if ($isHeader) {
        [void]$sb.AppendLine('      <w:pPr>')
        [void]$sb.AppendLine('        <w:spacing w:before="160" w:after="80"/>')
        [void]$sb.AppendLine('      </w:pPr>')
        [void]$sb.AppendLine('      <w:r>')
        [void]$sb.AppendLine('        <w:rPr>')
        [void]$sb.AppendLine('          <w:b/>')
        [void]$sb.AppendLine('          <w:color w:val="1D4ED8"/>')
        [void]$sb.AppendLine('          <w:sz w:val="24"/>')
        [void]$sb.AppendLine('        </w:rPr>')
        [void]$sb.AppendLine("        <w:t xml:space=""preserve"">$esc</w:t>")
        [void]$sb.AppendLine('      </w:r>')
    } elseif ($isTag) {
        [void]$sb.AppendLine('      <w:pPr>')
        [void]$sb.AppendLine('        <w:spacing w:before="40" w:after="40"/>')
        [void]$sb.AppendLine('      </w:pPr>')
        [void]$sb.AppendLine('      <w:r>')
        [void]$sb.AppendLine('        <w:rPr>')
        [void]$sb.AppendLine('          <w:b/>')
        [void]$sb.AppendLine('          <w:color w:val="0F172A"/>')
        [void]$sb.AppendLine('        </w:rPr>')
        [void]$sb.AppendLine("        <w:t xml:space=""preserve"">$esc</w:t>")
        [void]$sb.AppendLine('      </w:r>')
    } elseif ($isSep) {
        [void]$sb.AppendLine('      <w:r>')
        [void]$sb.AppendLine('        <w:rPr><w:color w:val="94A3B8"/></w:rPr>')
        [void]$sb.AppendLine("        <w:t xml:space=""preserve"">$esc</w:t>")
        [void]$sb.AppendLine('      </w:r>')
    } else {
        [void]$sb.AppendLine('      <w:r>')
        [void]$sb.AppendLine("        <w:t xml:space=""preserve"">$esc</w:t>")
        [void]$sb.AppendLine('      </w:r>')
    }
    [void]$sb.AppendLine('    </w:p>')
}

[void]$sb.AppendLine('    <w:sectPr/>')
[void]$sb.AppendLine('  </w:body>')
[void]$sb.AppendLine('</w:document>')

$newDocXml = $sb.ToString()

# Unpack temp_exam.zip to temp folder, replace document.xml, and pack to final docx
$tempDir = 'C:\Users\nguye\Downloads\KiemTraGiuaKy\10.2.0\temp_docx_build'
if (Test-Path $tempDir) { Remove-Item $tempDir -Recurse -Force }
[System.IO.Compression.ZipFile]::ExtractToDirectory('c:\Users\nguye\Downloads\KiemTraGiuaKy\10.2.0\temp_exam.zip', $tempDir)

$docXmlPath = [System.IO.Path]::Combine($tempDir, 'word', 'document.xml')
[System.IO.File]::WriteAllText($docXmlPath, $newDocXml, [System.Text.Encoding]::UTF8)

$outDocxPath = 'C:\Users\nguye\Downloads\ETS_TOEIC_2024_Test_06_Chuan.docx'
if (Test-Path $outDocxPath) { Remove-Item $outDocxPath -Force }
[System.IO.Compression.ZipFile]::CreateFromDirectory($tempDir, $outDocxPath)
Remove-Item $tempDir -Recurse -Force

Write-Output ("Successfully created standard Word file: " + $outDocxPath)
$f = Get-Item $outDocxPath
Write-Output ("File size: " + $f.Length + " bytes")
