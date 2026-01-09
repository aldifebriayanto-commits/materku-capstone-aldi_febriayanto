📚 Materku - Aplikasi Manajemen Materi Pembelajaran
Show Image
Show Image
Show Image
Show Image

Aplikasi mobile untuk mengelola dan berbagi materi pembelajaran dengan fitur CRUD, statistik visual, dan sinkronisasi cloud.

📥 Download APK
[⬇️ Download Materku v1.0.0 APK (24.4 MB)](https://github.com/aldifebriayanto-commits/materku-capstone-aldi_febriayanto/releases/download/v1.0.0/MaterKu-v1.0.0.apk)

System Requirements:

Android 5.0 (API Level 21) or higher
50 MB free storage
2 GB RAM minimum
📱 Screenshots
<div align="center">
Home Screen
Show Image

Material Detail
Show Image

Upload Material
Show Image

Favorites
Show Image

Downloads History
Show Image

Statistics Dashboard
Show Image

</div>
✨ Features
📖 Material Management
✅ Create - Upload materials (PDF, DOC, PPT, XLS, Images, Videos)
✅ Read - View material details with complete information
✅ Update - Edit and modify existing materials
✅ Delete - Remove unnecessary materials
✅ Search - Find materials by title, category, or description
✅ Filter - Filter by 22+ IT/Programming subject categories
⭐ Favorite System
✅ Mark/unmark materials as favorites
✅ Quick access to favorite materials
✅ Separate favorites list view
📥 Download Tracking
✅ Automatic download history recording
✅ View download details (timestamp, file info, category)
✅ Download statistics
📊 Statistics & Visualizations
✅ Bar Chart - Top 5 most downloaded materials
✅ Pie Chart - Material distribution by category
✅ Progress Bars - File type distribution analysis
✅ Summary Cards - Total materials, downloads, and categories
🌐 Offline/Online Mode
✅ Offline Mode - Full functionality with SQLite local database
✅ Online Mode - Sync with REST API server
✅ Auto-sync - Seamless data synchronization
🛠️ Tech Stack
Framework & Language
Flutter 3.24.5 - UI Framework
Dart 3.5.4 - Programming Language
State Management
Provider - Efficient state management solution
Local Database
SQLite (sqflite package) - Offline data storage
Path Provider - Local file system access
Data Visualization
fl_chart 0.69.0 - Beautiful charts and graphs
File Handling
file_picker - Multi-format file selection
image_picker - Camera and gallery integration
open_filex - File preview functionality
UI Components
Material Design 3 - Modern UI components
Custom Widgets - Reusable components
Responsive Design - Adaptive layouts
📚 Supported Subjects (22 Categories)
Programming & Algorithms (6)
Algoritma dan Pemrograman
Pemrograman Berbasis Objek (PBO)
Struktur Data
Pemrograman Web
Pemrograman Mobile
Pemrograman Berbasis Framework
Database & Data Science (5)
Basis Data
Data Mining
Big Data
Pembelajaran Mesin (Machine Learning)
Kecerdasan Buatan
Software Engineering (4)
Rekayasa Perangkat Lunak (RPL)
Analisis dan Perancangan Sistem
Manajemen Proyek TI
Pengujian Perangkat Lunak
Security (3)
Keamanan Informasi
Kriptografi
Ethical Hacking
Others (2)
Grafika Komputer
Lainnya
🚀 Installation
Prerequisites
Flutter SDK 3.24.5 or higher
Dart SDK 3.5.4 or higher
Android Studio / VS Code
Android SDK (API Level 21+)
Setup Instructions
Clone Repository
bash
   git clone https://github.com/aldifebriayanto-commits/materku-capstone-aldi_febriayanto.git
   cd materku-capstone-aldi_febriayanto
Install Dependencies
bash
   flutter pub get
Run Application
bash
   # Debug mode
   flutter run
   
   # Release mode
   flutter run --release
Build APK
bash
   flutter build apk --release
Build App Bundle (for Play Store)
bash
   flutter build appbundle --release
📊 Database Schema
Table: materials
Column	Type	Description
id	INTEGER	Primary Key (Auto Increment)
title	TEXT	Material title (NOT NULL)
description	TEXT	Material description
category	TEXT	Subject category (NOT NULL)
file_path	TEXT	Local file path (NOT NULL)
file_url	TEXT	Remote file URL
file_type	TEXT	File extension (pdf, doc, etc.)
file_size	INTEGER	File size in bytes
upload_date	TEXT	Upload timestamp (ISO 8601)
is_favorite	INTEGER	Favorite flag (0/1)
download_count	INTEGER	Number of downloads (default: 0)
last_accessed	TEXT	Last access timestamp
sync_status	INTEGER	Sync status (0: not synced, 1: synced)
created_at	TEXT	Creation timestamp
updated_at	TEXT	Last update timestamp
Table: downloads
Column	Type	Description
id	INTEGER	Primary Key (Auto Increment)
material_id	INTEGER	Foreign Key → materials(id)
material_title	TEXT	Material title
category	TEXT	Subject category
file_type	TEXT	File extension
download_date	TEXT	Download timestamp (ISO 8601)
file_path	TEXT	Downloaded file path
Indexes
sql
CREATE INDEX idx_materials_category ON materials(category);
CREATE INDEX idx_materials_favorite ON materials(is_favorite);
CREATE INDEX idx_materials_upload_date ON materials(upload_date);
CREATE INDEX idx_downloads_material_id ON downloads(material_id);
CREATE INDEX idx_downloads_date ON downloads(download_date);
Sample Queries
sql
-- Get all materials ordered by upload date
SELECT * FROM materials ORDER BY upload_date DESC;

-- Get favorite materials
SELECT * FROM materials WHERE is_favorite = 1;

-- Get materials by category
SELECT * FROM materials WHERE category = 'Pemrograman Web';

-- Get download history with material info
SELECT d.*, m.title, m.category 
FROM downloads d 
LEFT JOIN materials m ON d.material_id = m.id 
ORDER BY d.download_date DESC;

-- Get top 5 most downloaded materials
SELECT * FROM materials 
ORDER BY download_count DESC 
LIMIT 5;

-- Count materials by category
SELECT category, COUNT(*) as total 
FROM materials 
GROUP BY category 
ORDER BY total DESC;
🌐 API Documentation
Base URL
https://api.materku.com/api
Endpoints
1. Get All Materials
http
GET /materials
Query Parameters:

category (optional) - Filter by category
search (optional) - Search by title/description
limit (optional) - Number of results (default: 20)
offset (optional) - Pagination offset (default: 0)
Response:

json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "title": "Algoritma Sorting",
      "description": "Materi tentang algoritma sorting",
      "category": "Algoritma dan Pemrograman",
      "file_url": "https://...",
      "file_type": "pdf",
      "file_size": 2048000,
      "upload_date": "2025-01-09T10:30:00Z",
      "download_count": 42
    }
  ],
  "total": 150
}
2. Get Material by ID
http
GET /materials/:id
Response:

json
{
  "success": true,
  "data": {
    "id": 1,
    "title": "Algoritma Sorting",
    "description": "Materi lengkap tentang algoritma sorting",
    "category": "Algoritma dan Pemrograman",
    "file_url": "https://...",
    "file_type": "pdf",
    "file_size": 2048000,
    "upload_date": "2025-01-09T10:30:00Z",
    "download_count": 42
  }
}
3. Create Material
http
POST /materials
Content-Type: multipart/form-data
Body:

title: "New Material"
description: "Material description"
category: "Pemrograman Web"
file: [binary file]
Response:

json
{
  "success": true,
  "message": "Material uploaded successfully",
  "data": {
    "id": 151,
    "file_url": "https://...",
    "upload_date": "2025-01-10T08:15:00Z"
  }
}
4. Update Material
http
PUT /materials/:id
Content-Type: application/json
Body:

json
{
  "title": "Updated Title",
  "description": "Updated description",
  "category": "Data Mining"
}
5. Delete Material
http
DELETE /materials/:id
Response:

json
{
  "success": true,
  "message": "Material deleted successfully"
}
6. Record Download
http
POST /downloads
Content-Type: application/json
Body:

json
{
  "material_id": 1,
  "download_date": "2025-01-10T08:30:00Z"
}
📁 Project Structure
materku/
├── android/              # Android native code
├── ios/                  # iOS native code (if applicable)
├── lib/
│   ├── config/          # Configuration files
│   │   ├── api_config.dart
│   │   └── supabase_config.dart
│   ├── core/            # Core utilities
│   ├── database/        # Database helpers
│   │   └── database_helper.dart
│   ├── models/          # Data models
│   │   └── material_model.dart
│   ├── providers/       # State management
│   │   └── material_provider.dart
│   ├── screens/         # UI screens
│   │   ├── home_screen.dart
│   │   ├── detail_screen.dart
│   │   ├── upload_screen.dart
│   │   ├── favorites_screen.dart
│   │   ├── downloads_screen.dart
│   │   └── statistics_screen.dart
│   ├── services/        # Business logic
│   │   ├── api_service.dart
│   │   ├── database_service.dart
│   │   └── sync_manager.dart
│   ├── utils/           # Helper functions
│   ├── widgets/         # Reusable widgets
│   └── main.dart        # Entry point
├── screenshots/         # App screenshots
├── test/               # Unit tests
├── pubspec.yaml        # Dependencies
└── README.md          # This file
🧪 Testing
Run Tests
bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# View coverage report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
📦 Dependencies
yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  provider: ^6.1.1
  
  # Local Database
  sqflite: ^2.3.0
  path_provider: ^2.1.1
  path: ^1.8.3
  
  # File Handling
  file_picker: ^6.1.1
  image_picker: ^1.0.5
  open_filex: ^4.3.4
  
  # Data Visualization
  fl_chart: ^0.69.0
  
  # UI Components
  intl: ^0.18.1
  
  # HTTP & API
  http: ^1.1.2
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
👨‍💻 Developer
Aldi Febriayanto

NIM: A11.2023.15056
Kelas: A11.4708
Program Studi: Teknik Informatika
Universitas: Universitas Dian Nuswantoro
GitHub: @aldifebriayanto-commits
Email: aldifebriayanto@students.dinus.ac.id
📄 License
This project is licensed under the MIT License - see the LICENSE file for details.

🙏 Acknowledgments
Flutter Team - Amazing framework
Dosen Pembimbing - Guidance and support
Universitas Dian Nuswantoro - Educational support
Open Source Community - Various packages and libraries
📞 Contact & Support
GitHub Issues: Report Bug
Email: aldifebriayanto@students.dinus.ac.id
University: Universitas Dian Nuswantoro
🔄 Version History
v1.0.0 (January 10, 2025)
✅ Initial release
✅ Full CRUD functionality
✅ 22 subject categories
✅ Statistics with fl_chart
✅ Offline mode with SQLite
✅ Favorites system
✅ Download tracking
🚀 Future Improvements
 Cloud storage integration (Firebase/Supabase)
 User authentication system
 Material sharing between users
 Push notifications
 Dark mode support
 Export statistics to PDF
 Material comments and ratings
 Advanced search filters
 Material recommendations
Made with ❤️ using Flutter

Capstone Project - Mobile Programming - 2026

