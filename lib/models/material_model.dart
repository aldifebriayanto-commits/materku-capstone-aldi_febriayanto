// lib/models/material_model.dart

/// Model untuk material pembelajaran
/// Compatible with LocalDatabase & DatabaseHelper schema
class MaterialModel {
  final String? id;              // TEXT/STRING for local_database
  final String title;
  final String subject;
  final String type;             // 'pdf', 'doc', 'ppt', etc.
  final String filePath;         // Local file path or URL
  final String uploadedBy;
  final String uploadDate;
  final int downloadCount;
  final bool isFavorite;
  final String description;

  MaterialModel({
    this.id,
    required this.title,
    required this.subject,
    required this.type,
    required this.filePath,
    required this.uploadedBy,
    required this.uploadDate,
    this.downloadCount = 0,
    this.isFavorite = false,
    this.description = '',
  });

  /// Convert MaterialModel to Map for database insertion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subject': subject,
      'type': type,
      'filePath': filePath,
      'uploadedBy': uploadedBy,
      'uploadDate': uploadDate,
      'downloadCount': downloadCount,
      'isFavorite': isFavorite ? 1 : 0,
      'description': description,
    };
  }

  /// Create MaterialModel from database Map
  factory MaterialModel.fromMap(Map<String, dynamic> map) {
    return MaterialModel(
      id: map['id']?.toString(),
      title: map['title'] as String? ?? '',
      subject: map['subject'] as String? ?? '',
      type: map['type'] as String? ?? '',
      filePath: map['filePath'] as String? ?? '',
      uploadedBy: map['uploadedBy'] as String? ?? '',
      uploadDate: map['uploadDate'] as String? ?? '',
      downloadCount: map['downloadCount'] as int? ?? 0,
      isFavorite: (map['isFavorite'] as int?) == 1,
      description: map['description'] as String? ?? '',
    );
  }

  /// Convert to JSON for API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subject': subject,
      'type': type,
      'filePath': filePath,
      'uploadedBy': uploadedBy,
      'uploadDate': uploadDate,
      'downloadCount': downloadCount,
      'isFavorite': isFavorite,
      'description': description,
    };
  }

  /// Create from JSON (from API response)
  factory MaterialModel.fromJson(Map<String, dynamic> json) {
    return MaterialModel(
      id: json['id']?.toString(),
      title: json['title'] as String? ?? '',
      subject: json['subject'] as String? ?? '',
      type: json['type'] as String? ?? '',
      filePath: json['filePath'] as String? ?? '',
      uploadedBy: json['uploadedBy'] as String? ?? '',
      uploadDate: json['uploadDate'] as String? ?? '',
      downloadCount: json['downloadCount'] as int? ?? 0,
      isFavorite: json['isFavorite'] as bool? ?? false,
      description: json['description'] as String? ?? '',
    );
  }

  /// Copy with method for immutability
  MaterialModel copyWith({
    String? id,
    String? title,
    String? subject,
    String? type,
    String? filePath,
    String? uploadedBy,
    String? uploadDate,
    int? downloadCount,
    bool? isFavorite,
    String? description,
  }) {
    return MaterialModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      type: type ?? this.type,
      filePath: filePath ?? this.filePath,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      uploadDate: uploadDate ?? this.uploadDate,
      downloadCount: downloadCount ?? this.downloadCount,
      isFavorite: isFavorite ?? this.isFavorite,
      description: description ?? this.description,
    );
  }

  /// Get file extension from type or filePath
  String get fileExtension {
    if (type.isNotEmpty) return type.toLowerCase();
    if (filePath.contains('.')) {
      return filePath.split('.').last.toLowerCase();
    }
    return '';
  }

  /// Get file icon based on type
  String get fileIcon {
    switch (fileExtension) {
      case 'pdf':
        return '📄';
      case 'doc':
      case 'docx':
        return '📝';
      case 'ppt':
      case 'pptx':
        return '📊';
      case 'xls':
      case 'xlsx':
        return '📈';
      case 'zip':
      case 'rar':
        return '🗜️';
      case 'jpg':
      case 'jpeg':
      case 'png':
        return '🖼️';
      default:
        return '📁';
    }
  }

  /// Format upload date
  String get formattedUploadDate {
    try {
      final date = DateTime.parse(uploadDate);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        if (difference.inHours == 0) {
          return '${difference.inMinutes} menit yang lalu';
        }
        return '${difference.inHours} jam yang lalu';
      } else if (difference.inDays == 1) {
        return 'Kemarin';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} hari yang lalu';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return uploadDate;
    }
  }

  @override
  String toString() {
    return 'MaterialModel(id: $id, title: $title, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MaterialModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}