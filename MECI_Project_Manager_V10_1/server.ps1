param([int]$Port = 8080)
$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$DataDir = Join-Path $Root 'data'
$DataFile = Join-Path $DataDir 'cloud-data.json'
New-Item -ItemType Directory -Force -Path $DataDir | Out-Null
if (-not (Test-Path $DataFile)) {
  @{ revision = 0; updatedAt = $null; data = @{} } | ConvertTo-Json -Depth 100 | Set-Content -Encoding UTF8 $DataFile
}
$Mime = @{
  '.html'='text/html; charset=utf-8'; '.js'='text/javascript; charset=utf-8'; '.css'='text/css; charset=utf-8';
  '.json'='application/json; charset=utf-8'; '.webmanifest'='application/manifest+json'; '.svg'='image/svg+xml';
  '.png'='image/png'; '.jpg'='image/jpeg'; '.jpeg'='image/jpeg'; '.ico'='image/x-icon'
}
function Send-Bytes($ctx, [int]$status, [byte[]]$bytes, [string]$type) {
  $ctx.Response.StatusCode = $status
  $ctx.Response.ContentType = $type
  $ctx.Response.Headers['Cache-Control'] = 'no-store'
  $ctx.Response.Headers['Access-Control-Allow-Origin'] = '*'
  $ctx.Response.Headers['Access-Control-Allow-Headers'] = 'Content-Type, x-meci-key'
  $ctx.Response.Headers['Access-Control-Allow-Methods'] = 'GET, PUT, OPTIONS'
  $ctx.Response.ContentLength64 = $bytes.Length
  $ctx.Response.OutputStream.Write($bytes, 0, $bytes.Length)
  $ctx.Response.OutputStream.Close()
}
function Send-Text($ctx, [int]$status, [string]$text, [string]$type='application/json; charset=utf-8') {
  Send-Bytes $ctx $status ([Text.Encoding]::UTF8.GetBytes($text)) $type
}
function Read-Store { try { Get-Content -Raw -Encoding UTF8 $DataFile | ConvertFrom-Json } catch { [pscustomobject]@{revision=0;updatedAt=$null;data=@{}} } }
function Write-Store($payload) {
  $old = Read-Store
  $out = [ordered]@{ revision = ([int]$old.revision + 1); updatedAt = (Get-Date).ToUniversalTime().ToString('o'); data = $payload }
  $json = $out | ConvertTo-Json -Depth 100
  $tmp = "$DataFile.tmp"
  Set-Content -Encoding UTF8 -Path $tmp -Value $json
  Move-Item -Force $tmp $DataFile
  return $json
}
$listener = [System.Net.HttpListener]::new()
$listener.Prefixes.Add("http://+:$Port/")
$listener.Start()
$ip = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -notlike '169.254*' -and $_.IPAddress -ne '127.0.0.1' } | Select-Object -First 1 -ExpandProperty IPAddress)
Write-Host ''
Write-Host 'MECI Project Manager V10.1 dang chay.' -ForegroundColor Green
Write-Host "May tinh: http://localhost:$Port" -ForegroundColor Cyan
if ($ip) { Write-Host "Dien thoai cung Wi-Fi: http://$ip`:$Port" -ForegroundColor Yellow }
Write-Host 'Khong dong cua so nay khi dang su dung.' -ForegroundColor White
Write-Host ''
Start-Process "http://localhost:$Port"
while ($listener.IsListening) {
  $ctx = $listener.GetContext()
  try {
    $req = $ctx.Request
    $path = [Uri]::UnescapeDataString($req.Url.AbsolutePath)
    if ($req.HttpMethod -eq 'OPTIONS') { Send-Text $ctx 204 ''; continue }
    if ($path -eq '/api/health') { Send-Text $ctx 200 '{"ok":true,"version":"10.1"}'; continue }
    if ($path -eq '/api/data') {
      if ($req.HttpMethod -eq 'GET') {
        Send-Text $ctx 200 ((Read-Store) | ConvertTo-Json -Depth 100)
        continue
      }
      if ($req.HttpMethod -eq 'PUT') {
        $reader = New-Object IO.StreamReader($req.InputStream, $req.ContentEncoding)
        $body = $reader.ReadToEnd(); $reader.Close()
        try {
          $obj = $body | ConvertFrom-Json
          if ($null -eq $obj.data) { throw 'invalid_data' }
          Send-Text $ctx 200 (Write-Store $obj.data)
        } catch { Send-Text $ctx 400 '{"error":"invalid_json"}' }
        continue
      }
      Send-Text $ctx 405 '{"error":"method_not_allowed"}'
      continue
    }
    $rel = if ($path -eq '/') { 'index.html' } else { $path.TrimStart('/') }
    $full = [IO.Path]::GetFullPath((Join-Path $Root $rel))
    if (-not $full.StartsWith([IO.Path]::GetFullPath($Root)) -or -not (Test-Path $full) -or (Get-Item $full).PSIsContainer) {
      Send-Text $ctx 404 'Khong tim thay' 'text/plain; charset=utf-8'; continue
    }
    $ext = [IO.Path]::GetExtension($full).ToLowerInvariant()
    $type = if ($Mime.ContainsKey($ext)) { $Mime[$ext] } else { 'application/octet-stream' }
    Send-Bytes $ctx 200 ([IO.File]::ReadAllBytes($full)) $type
  } catch {
    try { Send-Text $ctx 500 ('{"error":"server_error"}') } catch {}
  }
}
