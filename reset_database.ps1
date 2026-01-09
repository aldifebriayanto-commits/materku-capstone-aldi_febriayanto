# Script untuk reset database jika ada masalah
# Jalankan ini di terminal PowerShell jika database corrupted

Write-Host "🗑️  Menghapus database lama..." -ForegroundColor Yellow

$dbPath = "$env:USERPROFILE\AppData\Local\com.example.materku\databases\materku.db"
$altPath = "$env:USERPROFILE\.config\materku\materku.db"

if (Test-Path $dbPath) {
    Remove-Item $dbPath -Force
    Write-Host "✅ Database dihapus: $dbPath" -ForegroundColor Green
}

if (Test-Path $altPath) {
    Remove-Item $altPath -Force
    Write-Host "✅ Database dihapus: $altPath" -ForegroundColor Green
}

Write-Host "`nDatabase akan dibuat ulang saat app dijalankan" -ForegroundColor Cyan
Write-Host "Jalankan: flutter run" -ForegroundColor Yellow
