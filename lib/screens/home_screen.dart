import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/material_provider.dart';
import '../widgets/material_card.dart';
import '../models/material_model.dart';
import 'upload_screen.dart';
import 'favorites_screen.dart';
import 'downloads_screen.dart';
import 'statistics_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  String _selectedSubject = 'Semua';
  final TextEditingController _searchController = TextEditingController();
  bool _isOfflineMode = false;

  // ✅ UPDATED: IT/Programming subjects only
  final List<String> subjects = [
    'Semua',
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

  @override
  void initState() {
    super.initState();
    _loadOfflineMode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<MaterialProvider>().fetchMaterials();
      }
    });
  }

  Future<void> _loadOfflineMode() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isOfflineMode = prefs.getBool('offline_mode') ?? false;
    });
  }

  Future<void> _toggleOfflineMode() async {
    final prefs = await SharedPreferences.getInstance();
    final newValue = !_isOfflineMode;
    await prefs.setBool('offline_mode', newValue);
    setState(() => _isOfflineMode = newValue);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                newValue ? Icons.offline_bolt : Icons.wifi,
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              Text(newValue ? 'Mode Offline Aktif' : 'Mode Online Aktif'),
            ],
          ),
          backgroundColor: newValue ? Colors.orange : Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<MaterialModel> _getFilteredMaterials(List<MaterialModel> materials) {
    List<MaterialModel> filtered = materials;

    if (_selectedSubject != 'Semua') {
      filtered = filtered.where((m) => m.subject == _selectedSubject).toList();
    }

    if (_searchController.text.isNotEmpty) {
      filtered = filtered
          .where((m) =>
      m.title.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          m.subject.toLowerCase().contains(_searchController.text.toLowerCase()))
          .toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const UploadScreen()),
          ).then((_) {
            context.read<MaterialProvider>().fetchMaterials();
          });
        },
        icon: const Icon(Icons.add),
        label: const Text('Unggah'),
        backgroundColor: const Color(0xFF7C3AED),
      )
          : null,
    );
  }

  Widget _buildBody() {
    return IndexedStack(
      index: _currentIndex,
      children: [
        _buildHomeTab(),
        const FavoritesScreen(),
        const DownloadsScreen(),
        const StatisticsScreen(),
      ],
    );
  }

  Widget _buildHomeTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF3B82F6), Color(0xFFA855F7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Offline Badge & Settings
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // ✅ CLICKABLE Offline Badge (Compact)
                    InkWell(
                      onTap: _toggleOfflineMode,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _isOfflineMode ? Colors.orange : Colors.white54,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          color: _isOfflineMode
                              ? Colors.orange.withOpacity(0.15)
                              : Colors.white.withOpacity(0.1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _isOfflineMode ? Icons.cloud_off : Icons.cloud_queue,
                              color: Colors.white,
                              size: 14,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              _isOfflineMode ? 'Offline' : 'Online',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // ✅ CLICKABLE Settings Button
                    InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const SettingsScreen(),
                          ),
                        ).then((_) => _loadOfflineMode());
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.settings,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Title
                const Row(
                  children: [
                    Icon(Icons.school, color: Colors.white, size: 32),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MaterKu',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Repository Materi Kuliah',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Search & Filters
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Cari materi...',
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                const SizedBox(height: 16),
                // Subject Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (int i = 0; i < (subjects.length > 5 ? 5 : subjects.length); i++)
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: FilterChip(
                            label: Text(subjects[i]),
                            selected: _selectedSubject == subjects[i],
                            onSelected: (_) {
                              setState(() {
                                _selectedSubject = subjects[i];
                              });
                            },
                            backgroundColor: Colors.grey[200],
                            selectedColor: const Color(0xFF3B82F6),
                            labelStyle: TextStyle(
                              color: _selectedSubject == subjects[i]
                                  ? Colors.white
                                  : Colors.grey[700],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      if (subjects.length > 5)
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: FilterChip(
                            label: const Text('Lainnya'),
                            selected: false,
                            onSelected: (_) {
                              _showAllSubjectsDialog();
                            },
                            backgroundColor: Colors.grey[200],
                            labelStyle: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Materials List
          Consumer<MaterialProvider>(
            builder: (context, provider, _) {
              final filtered = _getFilteredMaterials(provider.materials);

              if (provider.isLoading) {
                return const SizedBox(
                  height: 300,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                child: filtered.isEmpty
                    ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          'Belum ada materi',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                    : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    return MaterialCard(material: filtered[index]);
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF3B82F6),
        unselectedItemColor: Colors.grey[400],
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorit',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.download),
            label: 'Download',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Statistik',
          ),
        ],
      ),
    );
  }

  void _showAllSubjectsDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Title
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: const Text(
                'Pilih Mata Pelajaran',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(),
            // Subject List
            Expanded(
              child: ListView.builder(
                itemCount: subjects.length,
                itemBuilder: (context, index) {
                  final subject = subjects[index];
                  final isSelected = _selectedSubject == subject;

                  return ListTile(
                    title: Text(
                      subject,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? const Color(0xFF3B82F6) : Colors.black87,
                      ),
                    ),
                    leading: Icon(
                      isSelected ? Icons.check_circle : Icons.circle_outlined,
                      color: isSelected ? const Color(0xFF3B82F6) : Colors.grey,
                    ),
                    onTap: () {
                      setState(() {
                        _selectedSubject = subject;
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}