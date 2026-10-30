[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$json = [System.IO.File]::ReadAllText('C:\Users\ken03\.gemini\antigravity\scratch\google-map-stars-viewer\places.json', [System.Text.Encoding]::UTF8) | ConvertFrom-Json
$others = $json | Where-Object { $_.category -eq '其他' }

Write-Host "被歸類為「其他」的總數: $($others.Count)"
Write-Host "`n=== 前 50 筆「其他」名單抽查 ==="

$sample = $others | Select-Object -First 50
foreach ($s in $sample) {
    Write-Host "$($s.name)  [地址: $($s.address)]"
}
