# API Testing Guide

Panduan lengkap untuk testing REST API Materku.

## 🚀 Quick Start

### 1. Start Backend Server

```bash
cd materku-api
npm install
npm run dev
```

Server akan running di: `http://localhost:3000`

### 2. Health Check

```bash
curl http://localhost:3000/health
```

Expected response:
```json
{
  "status": "ok",
  "timestamp": "2026-01-08T10:00:00.000Z"
}
```

## 🧪 Testing Endpoints

### Using cURL

#### 1. Get All Materials
```bash
curl http://localhost:3000/api/materials
```

#### 2. Upload Material
```bash
curl -X POST http://localhost:3000/api/materials \
  -F "title=Test Material" \
  -F "subject=Matematika" \
  -F "type=PDF" \
  -F "uploadedBy=Tester" \
  -F "description=Test description" \
  -F "file=@/path/to/file.pdf"
```

#### 3. Update Material
```bash
curl -X PUT http://localhost:3000/api/materials/1 \
  -H "Content-Type: application/json" \
  -d '{"title":"Updated Title","isFavorite":1}'
```

#### 4. Delete Material
```bash
curl -X DELETE http://localhost:3000/api/materials/1
```

### Using Postman

1. **Import Collection:**
   - File → Import → Link
   - Paste: `https://www.getpostman.com/collections/YOUR_COLLECTION_ID`

2. **Environment Variables:**
   ```
   baseUrl: http://localhost:3000
   ```

3. **Test Requests:**
   - GET Materials
   - POST Upload
   - PUT Update
   - DELETE Remove
   - POST Record Download
   - GET Statistics

## 📱 Testing with Flutter App

### Enable Online Mode

1. Open app → Tap Settings (⚙️)
2. Toggle "Mode Online" ON
3. Check status indicator (should be green ✓)

### Test Flow

1. **Upload Material:**
   - Tap floating "+" button
   - Fill form
   - Select file (optional)
   - Submit
   - Check if appears in list

2. **View Details:**
   - Tap material card
   - Verify all data correct
   - Check if favorite toggle works

3. **Record Download:**
   - In detail screen, tap "Catat Download"
   - Go to Downloads tab
   - Verify download recorded

4. **Check Statistics:**
   - Go to Statistics tab
   - Verify charts update with new data

## 🔍 Debugging

### Check Server Logs

```bash
# In materku-api folder
npm run dev
```

Watch for:
- ✅ Request logs (GET, POST, PUT, DELETE)
- ❌ Error messages
- 📊 Database queries

### Check Flutter Logs

```bash
flutter run -v
```

Look for:
- API call logs
- Response data
- Error messages

### Common Issues

**Issue:** Connection refused
```
Solution: Make sure backend server is running
Check: http://localhost:3000/health
```

**Issue:** CORS error
```
Solution: Backend sudah configured CORS
Check: materku-api/server.js line with cors()
```

**Issue:** 404 Not Found
```
Solution: Check endpoint URL
Verify: http://localhost:3000/api/materials (not /materials)
```

## ✅ Test Checklist

- [ ] Health check returns OK
- [ ] Get all materials returns array
- [ ] Upload material creates new record
- [ ] Update material modifies data
- [ ] Delete material removes record
- [ ] Record download increments count
- [ ] Statistics returns correct summary
- [ ] Flutter app can connect to API
- [ ] Online mode toggle works
- [ ] Server status indicator shows correct state
