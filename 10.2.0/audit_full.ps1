$lines = Get-Content 'C:\Users\nguye\Downloads\KiemTraGiuaKy\10.2.0\exam_docx_dump.txt' -Encoding utf8

$questions = @{}
$currentQ = $null

foreach ($line in $lines) {
    if ($line -match '^\[Q:\s*(\d+)\]') {
        $currentQ = [int]$matches[1]
        $questions[$currentQ] = @{
            Number = $currentQ
            Prompt = ""
            A = ""
            B = ""
            C = ""
            D = ""
            Key = ""
            Category = ""
            Explanation = ""
        }
        continue
    }
    if ($currentQ -ne $null) {
        if ($line -match '^\[PROMPT\]:\s*(.*)') { $questions[$currentQ].Prompt = $matches[1] }
        elseif ($line -match '^\[A\]:\s*(.*)') { $questions[$currentQ].A = $matches[1] }
        elseif ($line -match '^\[B\]:\s*(.*)') { $questions[$currentQ].B = $matches[1] }
        elseif ($line -match '^\[C\]:\s*(.*)') { $questions[$currentQ].C = $matches[1] }
        elseif ($line -match '^\[D\]:\s*(.*)') { $questions[$currentQ].D = $matches[1] }
        elseif ($line -match '^\[KEY\]:\s*(.*)') { $questions[$currentQ].Key = $matches[1] }
        elseif ($line -match '^\[CATEGORY\]:\s*(.*)') { $questions[$currentQ].Category = $matches[1] }
        elseif ($line -match '^\[EXPLANATION\]:\s*(.*)') { $questions[$currentQ].Explanation = $matches[1] }
    }
}

$issues = @()
for ($i = 101; $i -le 200; $i++) {
    $q = $questions[$i]
    if ($null -eq $q) {
        $issues += ("Q" + $i + ": Không tìm thấy")
        continue
    }
    $prob = @()
    if ([string]::IsNullOrWhiteSpace($q.Prompt)) { $prob += "Thiếu PROMPT" }
    if ([string]::IsNullOrWhiteSpace($q.A)) { $prob += "Thiếu A" }
    if ([string]::IsNullOrWhiteSpace($q.B)) { $prob += "Thiếu B" }
    if ([string]::IsNullOrWhiteSpace($q.C)) { $prob += "Thiếu C" }
    if ([string]::IsNullOrWhiteSpace($q.D)) { $prob += "Thiếu D" }
    if ([string]::IsNullOrWhiteSpace($q.Key)) { $prob += "Thiếu KEY" }
    if ([string]::IsNullOrWhiteSpace($q.Category)) { $prob += "Thiếu CATEGORY" }
    if ([string]::IsNullOrWhiteSpace($q.Explanation)) { $prob += "Thiếu EXPLANATION" }
    
    if ($prob.Count -gt 0) {
        $issues += ("Q" + $i + ": " + ($prob -join " | "))
    }
}

Write-Output ("Total issues found: " + $issues.Count)
$issues | ForEach-Object { Write-Output $_ }
