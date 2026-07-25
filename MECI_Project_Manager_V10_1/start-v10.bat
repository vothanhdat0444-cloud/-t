@echo off
chcp 65001 >nul
cd /d "%~dp0"
net session >nul 2>&1
if %errorlevel% neq 0 (
  echo Dang yeu cau quyen de mo ket noi cho dien thoai...
  powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
  exit /b
)
powershell -NoProfile -ExecutionPolicy Bypass -Command "if (-not (Get-NetFirewallRule -DisplayName 'MECI V10 Port 8080' -ErrorAction SilentlyContinue)) { New-NetFirewallRule -DisplayName 'MECI V10 Port 8080' -Direction Inbound -Action Allow -Protocol TCP -LocalPort 8080 | Out-Null }"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0server.ps1" -Port 8080
pause
