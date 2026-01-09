# 🧪 API Testing Guide for Materku

## Setup

### 1. Start Backend Server
```bash
cd D:\materku-api
npm install
npm run dev
```

Server runs at: http://localhost:3000

### 2. Configure Flutter App

For **Android Emulator**:
- Base URL already set to: http://10.0.2.2:3000

For **Physical Device**:
1. Find your PC IP address:
   ```bash
   ipconfig
   # Look for IPv4 Address (e.g., 192.168.1.10)
   ```

2. Update lib/services/api_service.dart:
   ```dart
   static const String baseUrl = 'http://YOUR_IP:3000';
   ```

3. Make sure PC and phone on same WiFi network

## Testing Flow

### 1. Test Server Health
```bash
# From browser or Postman
GET http://localhost:3000/health
```

Expected response:
```json
{
  "status": "OK",
  "timestamp": "2026-01-08T...",
  "uptime": 123.456
}
```

### 2. Test in Flutter App

1. **Run App**:
   ```bash
   cd D:\materku
   flutter run
   ```

2. **Open Settings** (add settings button to main screen)

3. **Enable Online Mode**:
   - Toggle "Mode Online" switch
   - Check server status indicator

4. **Upload Material**:
   - Go to "Unggah" tab
   - Fill form
   - Upload file
   - Check console logs for API calls

5. **Verify on Server**:
   ```bash
   # Check database
   GET http://localhost:3000/api/materials
   ```

### 3. Test All Endpoints

#### List Materials
```bash
curl http://localhost:3000/api/materials
```

#### Upload Material
```bash
curl -X POST http://localhost:3000/api/materials \
  -F "title=Test Material" \
  -F "subject=Matematika" \
  -F "type=PDF" \
  -F "file=@test.pdf"
```

#### Update Material
```bash
curl -X PUT http://localhost:3000/api/materials/1 \
  -H "Content-Type: application/json" \
  -d '{"isFavorite": 1}'
```

#### Delete Material
```bash
curl -X DELETE http://localhost:3000/api/materials/1
```

#### Record Download
```bash
curl -X POST http://localhost:3000/api/materials/1/download
```

#### Get Statistics
```bash
curl http://localhost:3000/api/materials/stats/summary
```

## Troubleshooting

### Issue: Connection refused
- ✅ Check if server is running (
pm run dev)
- ✅ Check base URL in api_service.dart
- ✅ For physical device: PC and phone on same WiFi

### Issue: Timeout
- ✅ Increase timeout in api_service.dart
- ✅ Check file size (max 10MB by default)
- ✅ Check server logs for errors

### Issue: 404 Not Found
- ✅ Verify endpoint URL
- ✅ Check server routes in routes/materials.js

### Issue: CORS Error
- ✅ Check ALLOWED_ORIGINS in .env
- ✅ Add your origin to allowed list

## Production Deployment

### Deploy Backend

**Option 1: Heroku**
```bash
cd D:\materku-api
heroku create materku-api
git init
git add .
git commit -m "Initial commit"
git push heroku main
```

**Option 2: Railway**
1. Go to railway.app
2. New Project → Deploy from GitHub
3. Add environment variables

**Option 3: DigitalOcean**
1. Create Droplet (Ubuntu)
2. Install Node.js
3. Upload code
4. Run with PM2

### Update Flutter App
```dart
// lib/services/api_service.dart
static const String baseUrl = 'https://your-domain.com';
```

## Monitoring

Check server logs:
```bash
# Development
npm run dev

# Production
pm2 logs materku-api
```

Monitor API calls in Flutter:
```dart
// Enable debug prints
debugPrint('API Response: \');
```
