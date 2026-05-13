$env:PATH = [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH","User")
Set-Location "C:\Users\m2med\OneDrive\Desktop\QuitlyApp\backend"

# Get WSL2 IP dynamically (changes on each boot)
$wslIp = (wsl -d Ubuntu hostname -I).Trim().Split(' ')[0]
Write-Host "WSL2 IP: $wslIp"

# Parse .env and set env vars
Get-Content ".env" | Where-Object { $_ -match '^\s*[A-Z_]' -and $_ -notmatch '^\s*#' } | ForEach-Object {
  $parts = $_ -split '=', 2
  if ($parts.Count -eq 2) {
    $key = $parts[0].Trim()
    $val = $parts[1].Trim()
    if ($val.StartsWith('"') -and $val.EndsWith('"')) { $val = $val.Substring(1, $val.Length - 2) }
    [System.Environment]::SetEnvironmentVariable($key, $val, "Process")
  }
}

# Override DB + Redis URLs with the actual WSL2 IP
$env:DATABASE_URL = "postgresql://quitly:quitly_pass@${wslIp}:5432/quitly_db"
$env:REDIS_URL = "redis://${wslIp}:6379"

Write-Host "DATABASE_URL: $env:DATABASE_URL"
Write-Host "REDIS_URL:    $env:REDIS_URL"
Write-Host "Starting Quitly backend..."

npx tsx src/server.ts
