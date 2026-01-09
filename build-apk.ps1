
# Clean previous builds
Write-Host "🧹 Cleaning previous builds..." -ForegroundColor Yellow
flutter clean

# Get dependencies
Write-Host "📥 Getting dependencies..." -ForegroundColor Yellow
flutter pub get

# Build release APK
Write-Host "🔨 Building release APK (this may take 2-3 minutes)..." -ForegroundColor Yellow
flutter build apk --release

# Check if build succeeded
if (Test-Path "build\app\outputs\flutter-apk\app-release.apk") {
    Write-Host "✅ APK built successfully!" -ForegroundColor Green
    
    # Get APK size
    $apkSize = (Get-Item "build\app\outputs\flutter-apk\app-release.apk").Length / 1MB
    Write-Host "📏 APK Size: {0:N2} MB" -f $apkSize -ForegroundColor Cyan
    
    # Rename APK
    Write-Host "📝 Renaming APK..." -ForegroundColor Yellow
    Copy-Item "build\app\outputs\flutter-apk\app-release.apk" "materku-v1.0.0.apk"
    Write-Host "✅ APK saved as: materku-v1.0.0.apk" -ForegroundColor Green
    
    # Open folder
    Write-Host "📂 Opening APK location..." -ForegroundColor Yellow
    explorer.exe .
    
} else {
    Write-Host "❌ APK build failed!" -ForegroundColor Red
    Write-Host "   Check errors above and try again." -ForegroundColor Yellow
}

