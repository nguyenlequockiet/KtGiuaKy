$lines = Get-Content 'C:\Users\nguye\Downloads\KiemTraGiuaKy\10.2.0\exam_docx_dump.txt' -Encoding utf8

$passageMap = @{}
$currentPassageId = ""
$currentDocType = "Article / Notice"
$currentPassageTitle = ""
$currentPassageDocs = @()

$currentQ = $null
$qData = @{}
$questions = @()

function Escape-DartString($str) {
    if ($null -eq $str) { return "" }
    $s = $str -replace '\\', '\\' -replace "'", "\'" -replace '\$', '\$'
    $s = $s -replace '\[cite:\s*\d+\]', ''
    $s = $s -replace '&gt;', '>' -replace '&lt;', '<' -replace '&amp;', '&'
    return $s.Trim()
}

$i = 0
while ($i -lt $lines.Count) {
    $line = $lines[$i].Trim()

    if ($line -match '^\[PASSAGE_SET:\s*([^\]]+)\]') {
        $setRange = $matches[1].Trim()
        $currentPassageId = "passage_" + ($setRange -replace '-', '_')
        $currentPassageTitle = "Đoạn văn câu " + $setRange
        $currentDocType = "Reading Passage"
        $currentPassageDocs = @()
        $passageMap[$currentPassageId] = @{
            Id = $currentPassageId
            DocType = $currentDocType
            Title = $currentPassageTitle
            Content = ""
        }
        $i++
        continue
    }

    if ($line -match '^\[DOC_TYPE\]:\s*(.*)' -or $line -match '^\[DOC_1_TYPE\]:\s*(.*)') {
        $currentDocType = $matches[1].Trim()
        if ($passageMap.ContainsKey($currentPassageId)) {
            $passageMap[$currentPassageId].DocType = $currentDocType
        }
        $i++
        continue
    }

    if ($line -match '^\[TITLE\]:\s*(.*)') {
        $currentPassageTitle = $matches[1].Trim()
        if ($passageMap.ContainsKey($currentPassageId)) {
            $passageMap[$currentPassageId].Title = $currentPassageTitle
        }
        $i++
        continue
    }

    if ($line -match '^\[CONTENT\]:' -or $line -match '^\[DOC_\d+_CONTENT\]:') {
        $contentLines = @()
        $i++
        while ($i -lt $lines.Count -and -not ($lines[$i] -match '^\[Q:\s*\d+\]') -and -not ($lines[$i] -match '^\[PASSAGE_SET') -and -not ($lines[$i] -match '^\[DOC_\d+_') -and -not ($lines[$i] -match '^\[PART')) {
            if ($lines[$i].Trim().Length -gt 0) {
                $contentLines += $lines[$i].Trim()
            }
            $i++
        }
        $docContent = $contentLines -join "`n`n"
        if ($passageMap.ContainsKey($currentPassageId)) {
            if ([string]::IsNullOrWhiteSpace($passageMap[$currentPassageId].Content)) {
                $passageMap[$currentPassageId].Content = $docContent
            } else {
                $passageMap[$currentPassageId].Content += "`n`n--- TIẾP THEO ---`n`n" + $docContent
            }
        }
        continue
    }

    if ($line -match '^\[Q:\s*(\d+)\]') {
        if ($null -ne $currentQ) {
            $questions += $qData
        }
        $qNum = [int]$matches[1]
        $currentQ = $qNum
        $part = if ($qNum -le 130) { "PartType.part5" } elseif ($qNum -le 146) { "PartType.part6" } else { "PartType.part7" }
        $passId = if ($qNum -le 130) { "null" } else { "'" + $currentPassageId + "'" }
        
        $qData = @{
            Number = $qNum
            Part = $part
            PassageId = $passId
            Prompt = ""
            A = ""
            B = ""
            C = ""
            D = ""
            Key = "A"
            Category = if ($qNum -le 130) { "Từ vựng & Ngữ pháp" } elseif ($qNum -le 146) { "Điền từ vào đoạn văn (Part 6)" } else { "Đọc hiểu văn bản (Part 7)" }
            Explanation = ""
        }
        $i++
        continue
    }

    if ($null -ne $currentQ) {
        if ($line -match '^\[PROMPT\]:\s*(.*)') { $qData.Prompt = $matches[1].Trim() }
        elseif ($line -match '^\[A\]:\s*(.*)') { $qData.A = $matches[1].Trim() }
        elseif ($line -match '^\[B\]:\s*(.*)') { $qData.B = $matches[1].Trim() }
        elseif ($line -match '^\[C\]:\s*(.*)') { $qData.C = $matches[1].Trim() }
        elseif ($line -match '^\[D\]:\s*(.*)') { $qData.D = $matches[1].Trim() }
        elseif ($line -match '^\[KEY\]:\s*([A-D])') { $qData.Key = $matches[1].Trim() }
        elseif ($line -match '^\[CATEGORY\]:\s*(.*)') { $qData.Category = $matches[1].Trim() }
        elseif ($line -match '^\[EXPLANATION\]:\s*(.*)') { $qData.Explanation = $matches[1].Trim() }
    }

    $i++
}

if ($null -ne $currentQ) {
    $questions += $qData
}

Write-Output ("Total passages extracted: " + $passageMap.Count)
Write-Output ("Total questions extracted: " + $questions.Count)

# Generate Dart file
$dart = New-Object System.Text.StringBuilder
[void]$dart.AppendLine("// ignore_for_file: unnecessary_string_escapes")
[void]$dart.AppendLine("// Generated TOEIC ETS 2024 Test 06 data from EXAM.docx")
[void]$dart.AppendLine("import '../models/exam_models.dart';`n")

# Passages
[void]$dart.AppendLine("final Map<String, ReadingPassage> etsTest06Passages = {")
foreach ($key in $passageMap.Keys) {
    $p = $passageMap[$key]
    $docTypeEsc = Escape-DartString $p.DocType
    $titleEsc = Escape-DartString $p.Title
    $contentEsc = Escape-DartString $p.Content
    [void]$dart.AppendLine("  '${key}': const ReadingPassage(")
    [void]$dart.AppendLine("    id: '${key}',")
    [void]$dart.AppendLine("    documentType: '${docTypeEsc}',")
    [void]$dart.AppendLine("    title: '${titleEsc}',")
    [void]$dart.AppendLine("    content: '''${contentEsc}''',")
    [void]$dart.AppendLine("  ),")
}
[void]$dart.AppendLine("};`n")

# Questions
[void]$dart.AppendLine("List<QuestionItem> getEtsTest06Questions() {")
[void]$dart.AppendLine("  return [")
foreach ($q in $questions) {
    $num = $q.Number
    $prompt = $q.Prompt
    if ([string]::IsNullOrWhiteSpace($prompt)) {
        if ($num -ge 131 -and $num -le 146) {
            $prompt = "Chọn từ hoặc câu thích hợp nhất để điền vào vị trí [$num] trong đoạn văn trên."
        } else {
            $prompt = "Câu hỏi số $num."
        }
    }
    $promptEsc = Escape-DartString $prompt
    $catEsc = Escape-DartString $q.Category
    $expEsc = Escape-DartString $q.Explanation
    $aEsc = Escape-DartString $q.A
    $bEsc = Escape-DartString $q.B
    $cEsc = Escape-DartString $q.C
    $dEsc = Escape-DartString $q.D
    $keyEsc = $q.Key
    $part = $q.Part
    $passId = $q.PassageId

    [void]$dart.AppendLine("    QuestionItem(")
    [void]$dart.AppendLine("      number: $num,")
    [void]$dart.AppendLine("      part: $part,")
    [void]$dart.AppendLine("      categoryName: '$catEsc',")
    [void]$dart.AppendLine("      prompt: '$promptEsc',")
    [void]$dart.AppendLine("      passageId: $passId,")
    [void]$dart.AppendLine("      correctChoiceKey: '$keyEsc',")
    [void]$dart.AppendLine("      explanation: '$expEsc',")
    [void]$dart.AppendLine("      choices: const [")
    [void]$dart.AppendLine("        QuestionChoice(key: 'A', content: '$aEsc'),")
    [void]$dart.AppendLine("        QuestionChoice(key: 'B', content: '$bEsc'),")
    [void]$dart.AppendLine("        QuestionChoice(key: 'C', content: '$cEsc'),")
    [void]$dart.AppendLine("        QuestionChoice(key: 'D', content: '$dEsc'),")
    [void]$dart.AppendLine("      ],")
    [void]$dart.AppendLine("    ),")
}
[void]$dart.AppendLine("  ];")
[void]$dart.AppendLine("}")

$dartFile = 'c:\Users\nguye\Downloads\KiemTraGiuaKy\10.2.0\Lib\data\ets_2024_test_06_data.dart'
[System.IO.File]::WriteAllText($dartFile, $dart.ToString(), [System.Text.Encoding]::UTF8)

Write-Output ("Successfully generated " + $dartFile)
