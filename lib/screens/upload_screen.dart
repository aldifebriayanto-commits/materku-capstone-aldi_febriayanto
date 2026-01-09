import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../models/material_model.dart';
import '../providers/material_provider.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _uploaderController = TextEditingController();

  String _selectedSubject = 'Algoritma dan Pemrograman';
  String _selectedType = 'pdf';
  String? _selectedFilePath;
  String? _selectedFileName;
  bool _isUploading = false;

  // ✅ UPDATED: IT/Programming subjects only (22 subjects)
  final List<String> _subjects = [
    // Pemrograman & Algoritma
    'Algoritma dan Pemrograman',
    'Pemrograman Berbasis Objek (PBO)',
    'Struktur Data',
    'Pemrograman Web',
    'Pemrograman Mobile',
    'Pemrograman Berbasis Framework',
    // Database & Data Science
    'Basis Data',
    'Data Mining',
    'Big Data',
    'Pembelajaran Mesin (Machine Learning)',
    'Kecerdasan Buatan',
    // Software Engineering
    'Rekayasa Perangkat Lunak (RPL)',
    'Analisis dan Perancangan Sistem',
    'Manajemen Proyek TI',
    'Pengujian Perangkat Lunak',
    // Security
    'Keamanan Informasi',
    'Kriptografi',
    'Ethical Hacking',
    // Others
    'Grafika Komputer',
    'Lainnya',
  ];

  final List<String> _fileTypes = [
    'pdf',
    'doc',
    'docx',
    'ppt',
    'pptx',
    'xls',
    'xlsx',
    'txt',
    'jpg',
    'png',
    'mp4',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _uploaderController.dispose();
    super.dispose();
  }

  // ========================================================================
  // SHOW FILE TYPE PICKER DIALOG
  // ========================================================================

  Future<void> _showFileTypePicker() async {
    return showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                const Text(
                  'Pilih Jenis File',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pilih jenis file yang ingin diunggah',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const Divider(height: 32),

                // Document Option
                _FileTypeOption(
                  icon: Icons.description,
                  title: 'Dokumen',
                  subtitle: 'PDF, Word, Excel, PowerPoint',
                  color: Colors.blue,
                  onTap: () {
                    Navigator.pop(context);
                    _pickDocument();
                  },
                ),

                // Image Option
                _FileTypeOption(
                  icon: Icons.image,
                  title: 'Foto / Gambar',
                  subtitle: 'Ambil foto atau pilih dari galeri',
                  color: Colors.green,
                  onTap: () {
                    Navigator.pop(context);
                    _showImageSourceDialog();
                  },
                ),

                // Video Option
                _FileTypeOption(
                  icon: Icons.videocam,
                  title: 'Video',
                  subtitle: 'Rekam video atau pilih dari galeri',
                  color: Colors.purple,
                  onTap: () {
                    Navigator.pop(context);
                    _showVideoSourceDialog();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ========================================================================
  // DOCUMENT PICKER
  // ========================================================================

  Future<void> _pickDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'ppt', 'pptx', 'xls', 'xlsx', 'txt'],
      );

      if (result != null) {
        setState(() {
          _selectedFilePath = result.files.single.path;
          _selectedFileName = result.files.single.name;
          final ext = result.files.single.extension?.toLowerCase() ?? 'pdf';
          _selectedType = ext;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('📄 Dokumen terpilih: ${result.files.single.name}'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error memilih dokumen: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ========================================================================
  // IMAGE PICKER
  // ========================================================================

  Future<void> _showImageSourceDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pilih Sumber Gambar'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.green),
                title: const Text('Kamera'),
                subtitle: const Text('Ambil foto baru'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromSource(ImageSource.camera);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.green),
                title: const Text('Galeri'),
                subtitle: const Text('Pilih dari galeri'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromSource(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImageFromSource(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedFilePath = image.path;
          _selectedFileName = image.name;
          _selectedType = image.name.toLowerCase().endsWith('.png') ? 'png' : 'jpg';
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('📷 Foto terpilih: ${image.name}'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error mengambil foto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ========================================================================
  // VIDEO PICKER
  // ========================================================================

  Future<void> _showVideoSourceDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pilih Sumber Video'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.videocam, color: Colors.purple),
                title: const Text('Rekam Video'),
                subtitle: const Text('Rekam video baru'),
                onTap: () {
                  Navigator.pop(context);
                  _pickVideoFromSource(ImageSource.camera);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.video_library, color: Colors.purple),
                title: const Text('Galeri Video'),
                subtitle: const Text('Pilih dari galeri'),
                onTap: () {
                  Navigator.pop(context);
                  _pickVideoFromSource(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickVideoFromSource(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? video = await picker.pickVideo(
        source: source,
        maxDuration: const Duration(minutes: 5),
      );

      if (video != null) {
        setState(() {
          _selectedFilePath = video.path;
          _selectedFileName = video.name;
          _selectedType = 'mp4';
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('🎥 Video terpilih: ${video.name}'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error mengambil video: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ========================================================================
  // UPLOAD MATERIAL
  // ========================================================================

  Future<void> _uploadMaterial() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon lengkapi semua field')),
      );
      return;
    }

    if (_selectedFilePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon pilih file terlebih dahulu')),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final provider = context.read<MaterialProvider>();

      final material = MaterialModel(
        id: 'mat_${DateTime.now().millisecondsSinceEpoch}',
        title: _titleController.text.trim(),
        subject: _selectedSubject,
        type: _selectedType,
        description: _descriptionController.text.trim(),
        uploadedBy: _uploaderController.text.trim(),
        uploadDate: DateTime.now().toIso8601String(),
        filePath: _selectedFilePath!,
        downloadCount: 0,
        isFavorite: false,
      );

      final success = await provider.addMaterial(material);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Materi berhasil diunggah!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  // ========================================================================
  // BUILD UI
  // ========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Unggah Materi'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Title Field
            _buildTextField(
              controller: _titleController,
              label: 'Judul Materi',
              icon: Icons.title,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Judul tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            // Subject Dropdown
            _buildDropdown(
              value: _selectedSubject,
              label: 'Mata Pelajaran',
              icon: Icons.book,
              items: _subjects,
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedSubject = value);
                }
              },
            ),
            const SizedBox(height: 12),

            // File Type Dropdown
            _buildDropdown(
              value: _selectedType,
              label: 'Jenis File',
              icon: Icons.insert_drive_file,
              items: _fileTypes,
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedType = value);
                }
              },
              displayTransform: (value) => value.toUpperCase(),
            ),
            const SizedBox(height: 12),

            // Description Field
            _buildTextField(
              controller: _descriptionController,
              label: 'Deskripsi',
              icon: Icons.description,
              maxLines: 4,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Deskripsi tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            // Uploader Field
            _buildTextField(
              controller: _uploaderController,
              label: 'Nama Pengunggah',
              icon: Icons.person,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nama tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // File Preview
            if (_selectedFileName != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green.shade600),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'File terpilih:',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          Text(
                            _selectedFileName!,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _selectedFilePath = null;
                          _selectedFileName = null;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // ✅ SINGLE FILE PICKER BUTTON
            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _showFileTypePicker,
                icon: const Icon(Icons.attach_file, size: 24),
                label: const Text(
                  'Pilih File',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Upload Button
            SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: _isUploading ? null : _uploadMaterial,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isUploading
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                    : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_upload),
                    SizedBox(width: 8),
                    Text(
                      'Unggah Materi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========================================================================
  // HELPER WIDGETS
  // ========================================================================

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: maxLines > 1
              ? Padding(
            padding: EdgeInsets.only(bottom: (maxLines * 20).toDouble()),
            child: Icon(icon),
          )
              : Icon(icon),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required String label,
    required IconData icon,
    required List<String> items,
    required void Function(String?) onChanged,
    String Function(String)? displayTransform,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(displayTransform?.call(item) ?? item),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}

// ==========================================================================
// FILE TYPE OPTION WIDGET
// ==========================================================================

class _FileTypeOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _FileTypeOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 28),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
      onTap: onTap,
    );
  }
}