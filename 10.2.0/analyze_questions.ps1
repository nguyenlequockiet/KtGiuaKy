$lines = Get-Content 'C:\Users\nguye\Downloads\KiemTraGiuaKy\10.2.0\exam_docx_dump.txt' -Encoding utf8
$questions = @{}
$currentQ = $null

foreach ($line in $lines) {
    if ($line -match '\[Q:\s*(\d+)\]') {
        $qNum = [int]$matches[1]
        $currentQ = $qNum
        $questions[$qNum] = @{
            Number = $qNum
            HasPrompt = $false
            A = $null
            B = $null
            C = $null
            D = $null
            Key = $null
        }
    } elseif ($currentQ -ne $null) {
        if ($line -match '\[PROMPT\]:\s*(.*)') { 
            $promptVal = $matches[1].Trim()
            if ($promptVal.Length -gt 0) { $questions[$currentQ].HasPrompt = $true }
        }
        if ($line -match '\[A\]:\s*(.*)') { $questions[$currentQ].A = $matches[1].Trim() }
        if ($line -match '\[B\]:\s*(.*)') { $questions[$currentQ].B = $matches[1].Trim() }
        if ($line -match '\[C\]:\s*(.*)') { $questions[$currentQ].C = $matches[1].Trim() }
        if ($line -match '\[D\]:\s*(.*)') { $questions[$currentQ].D = $matches[1].Trim() }
        if ($line -match '\[KEY\]:\s*([A-D])') { $questions[$currentQ].Key = $matches[1].Trim() }
    }
}

Write-Output ("Total questions found in docx: " + $questions.Count)
$missing = @()
$incomplete = @()

for ($i = 101; $i -le 200; $i++) {
    if (-not $questions.ContainsKey($i)) {
        $missing += $i
    } else {
        $q = $questions[$i]
        $reasons = @()
        if (-not $q.HasPrompt) { $reasons += "Thiếu PROMPT" }
        if ([string]::IsNullOrWhiteSpace($q.A)) { $reasons += "Thiếu A" }
        if ([string]::IsNullOrWhiteSpace($q.B)) { $reasons += "Thiếu B" }
        if ([string]::IsNullOrWhiteSpace($q.C)) { $reasons += "Thiếu C" }
        if ([string]::IsNullOrWhiteSpace($q.D)) { $reasons += "Thiếu D" }
        if ([string]::IsNullOrWhiteSpace($q.Key)) { $reasons += "Thiếu KEY" }
        
        if ($reasons.Count -gt 0) {
            $incomplete += ("Câu " + $i + ": " + ($reasons -join ", "))
        }
    }
}

Write-Output ("Missing questions: " + ($missing -join ', '))
Write-Output ("Incomplete questions count: " + $incomplete.Count)
$incomplete | ForEach-Object { Write-Output $_ }
