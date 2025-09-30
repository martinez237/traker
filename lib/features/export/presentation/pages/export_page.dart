import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/di/providers.dart';
import '../../../../domain/entities/mood_entry.dart';

class ExportPage extends ConsumerStatefulWidget {
  const ExportPage({super.key});

  @override
  ConsumerState<ExportPage> createState() => _ExportPageState();
}

class _ExportPageState extends ConsumerState<ExportPage>
    with TickerProviderStateMixin {
  bool _loading = false;
  String? _loadingMessage;

  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _pulseController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  static final _uuid = Uuid();

  @override
  void initState() {
    super.initState();

    // Initialiser les animations
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Démarrer les animations
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 100), () {
      _slideController.forward();
    });
    Future.delayed(const Duration(milliseconds: 200), () {
      _scaleController.forward();
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _exportJSON() async {
    setState(() {
      _loading = true;
      _loadingMessage = 'Préparation des données JSON...';
    });

    _pulseController.repeat(reverse: true);

    try {
      final repo = ref.read(moodRepositoryProvider);
      final start = DateTime.utc(2015, 1, 1);
      final end = DateTime.utc(2100, 12, 31);
      final entries = await repo.getEntriesInRange(start, end);

      setState(() => _loadingMessage = 'Génération du fichier JSON...');

      final json = jsonEncode(entries.map((e) => {
        'id': e.id,
        'date': e.date.toIso8601String(),
        'emotion': e.emotion,
        'intensity': e.intensity,
        'note': e.note,
        'tags': e.tags,
        'createdAt': e.createdAt.toIso8601String(),
        'updatedAt': e.updatedAt.toIso8601String(),
      }).toList());

      setState(() => _loadingMessage = 'Partage du fichier...');

      await Share.shareXFiles([
        XFile.fromData(
          utf8.encode(json),
          name: 'mood_export_${DateTime.now().millisecondsSinceEpoch}.json',
          mimeType: 'application/json',
        )
      ]);

      _showCustomSnackBar('✨ Export JSON réussi (${entries.length} entrées)', true);
    } catch (e) {
      _showCustomSnackBar('Erreur lors de l\'export JSON: ${e.toString()}', false);
    } finally {
      setState(() {
        _loading = false;
        _loadingMessage = null;
      });
      _pulseController.reset();
    }
  }

  Future<void> _exportCSV() async {
    setState(() {
      _loading = true;
      _loadingMessage = 'Préparation des données CSV...';
    });

    _pulseController.repeat(reverse: true);

    try {
      final repo = ref.read(moodRepositoryProvider);
      final start = DateTime.utc(2015, 1, 1);
      final end = DateTime.utc(2100, 12, 31);
      final entries = await repo.getEntriesInRange(start, end);

      setState(() => _loadingMessage = 'Génération du fichier CSV...');

      final rows = <List<dynamic>>[
        ['id', 'date', 'emotion', 'intensity', 'note', 'tags', 'createdAt', 'updatedAt'],
        ...entries.map((e) => [
          e.id,
          e.date.toIso8601String(),
          e.emotion,
          e.intensity,
          e.note ?? '',
          e.tags.join('|'), // Utiliser | comme séparateur pour éviter les conflits
          e.createdAt.toIso8601String(),
          e.updatedAt.toIso8601String(),
        ]),
      ];

      final csvStr = const ListToCsvConverter().convert(rows);

      setState(() => _loadingMessage = 'Partage du fichier...');

      await Share.shareXFiles([
        XFile.fromData(
          utf8.encode(csvStr),
          name: 'mood_export_${DateTime.now().millisecondsSinceEpoch}.csv',
          mimeType: 'text/csv',
        )
      ]);

      _showCustomSnackBar('📊 Export CSV réussi (${entries.length} entrées)', true);
    } catch (e) {
      _showCustomSnackBar('Erreur lors de l\'export CSV: ${e.toString()}', false);
    } finally {
      setState(() {
        _loading = false;
        _loadingMessage = null;
      });
      _pulseController.reset();
    }
  }

  Future<void> _importJSON() async {
    setState(() {
      _loading = true;
      _loadingMessage = 'Sélection du fichier JSON...';
    });

    _pulseController.repeat(reverse: true);

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        setState(() {
          _loading = false;
          _loadingMessage = null;
        });
        _pulseController.reset();
        return;
      }

      setState(() => _loadingMessage = 'Lecture du fichier JSON...');

      final file = result.files.first;
      final content = utf8.decode(file.bytes!);

      setState(() => _loadingMessage = 'Analyse des données...');

      final jsonData = jsonDecode(content) as List<dynamic>;
      final entries = <MoodEntry>[];

      int validEntries = 0;
      int invalidEntries = 0;

      for (final item in jsonData) {
        try {
          if (item is! Map<String, dynamic>) {
            invalidEntries++;
            continue;
          }

          final entry = MoodEntry(
            id: item['id']?.toString() ?? _uuid.v4(),
            date: DateTime.parse(item['date'] ?? DateTime.now().toIso8601String()),
            emotion: item['emotion']?.toString() ?? 'neutral',
            intensity: (item['intensity'] as num?)?.toInt() ?? 3,
            note: item['note']?.toString(),
            tags: (item['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
            createdAt: DateTime.parse(item['createdAt'] ?? DateTime.now().toIso8601String()),
            updatedAt: DateTime.parse(item['updatedAt'] ?? DateTime.now().toIso8601String()),
          );

          // Validation des données
          if (entry.intensity < 1 || entry.intensity > 5) {
            invalidEntries++;
            continue;
          }

          entries.add(entry);
          validEntries++;
        } catch (e) {
          invalidEntries++;
          continue;
        }
      }

      if (entries.isEmpty) {
        throw Exception('Aucune entrée valide trouvée dans le fichier');
      }

      setState(() => _loadingMessage = 'Importation des données ($validEntries entrées)...');

      final repo = ref.read(moodRepositoryProvider);
      int importedCount = 0;

      for (final entry in entries) {
        try {
          await repo.upsertEntry(entry);
          importedCount++;
        } catch (e) {
          // Continuer même si une entrée échoue
          continue;
        }
      }

      String message = '📥 Import JSON réussi: $importedCount entrées importées';
      if (invalidEntries > 0) {
        message += ' ($invalidEntries ignorées)';
      }

      _showCustomSnackBar(message, true);
    } catch (e) {
      _showCustomSnackBar('Erreur lors de l\'import JSON: ${e.toString()}', false);
    } finally {
      setState(() {
        _loading = false;
        _loadingMessage = null;
      });
      _pulseController.reset();
    }
  }

  Future<void> _importCSV() async {
    setState(() {
      _loading = true;
      _loadingMessage = 'Sélection du fichier CSV...';
    });

    _pulseController.repeat(reverse: true);

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        setState(() {
          _loading = false;
          _loadingMessage = null;
        });
        _pulseController.reset();
        return;
      }

      setState(() => _loadingMessage = 'Lecture du fichier CSV...');

      final file = result.files.first;
      final content = utf8.decode(file.bytes!);

      setState(() => _loadingMessage = 'Analyse des données CSV...');

      final csvData = const CsvToListConverter().convert(content);

      if (csvData.isEmpty) {
        throw Exception('Fichier CSV vide');
      }

      // Première ligne = headers
      final headers = csvData.first.map((e) => e.toString().toLowerCase()).toList();
      final dataRows = csvData.skip(1).toList();

      // Vérifier les colonnes requises
      final requiredColumns = ['id', 'date', 'emotion', 'intensity'];
      for (final col in requiredColumns) {
        if (!headers.contains(col)) {
          throw Exception('Colonne manquante: $col');
        }
      }

      final entries = <MoodEntry>[];
      int validEntries = 0;
      int invalidEntries = 0;

      setState(() => _loadingMessage = 'Conversion des données...');

      for (final row in dataRows) {
        try {
          if (row.length != headers.length) {
            invalidEntries++;
            continue;
          }

          final data = Map<String, dynamic>.fromIterables(headers, row);

          final entry = MoodEntry(
            id: data['id']?.toString() ?? _uuid.v4(),
            date: DateTime.parse(data['date']?.toString() ?? DateTime.now().toIso8601String()),
            emotion: data['emotion']?.toString() ?? 'neutral',
            intensity: int.tryParse(data['intensity']?.toString() ?? '3') ?? 3,
            note: data['note']?.toString().isEmpty == true ? null : data['note']?.toString(),
            tags: data['tags']?.toString().split('|').where((tag) => tag.isNotEmpty).toList() ?? [],
            createdAt: DateTime.tryParse(data['createdat']?.toString() ?? '') ?? DateTime.now(),
            updatedAt: DateTime.tryParse(data['updatedat']?.toString() ?? '') ?? DateTime.now(),
          );

          // Validation des données
          if (entry.intensity < 1 || entry.intensity > 5) {
            invalidEntries++;
            continue;
          }

          entries.add(entry);
          validEntries++;
        } catch (e) {
          invalidEntries++;
          continue;
        }
      }

      if (entries.isEmpty) {
        throw Exception('Aucune entrée valide trouvée dans le fichier CSV');
      }

      setState(() => _loadingMessage = 'Importation des données ($validEntries entrées)...');

      final repo = ref.read(moodRepositoryProvider);
      int importedCount = 0;

      for (final entry in entries) {
        try {
          await repo.upsertEntry(entry);
          importedCount++;
        } catch (e) {
          // Continuer même si une entrée échoue
          continue;
        }
      }

      String message = '📥 Import CSV réussi: $importedCount entrées importées';
      if (invalidEntries > 0) {
        message += ' ($invalidEntries ignorées)';
      }

      _showCustomSnackBar(message, true);
    } catch (e) {
      _showCustomSnackBar('Erreur lors de l\'import CSV: ${e.toString()}', false);
    } finally {
      setState(() {
        _loading = false;
        _loadingMessage = null;
      });
      _pulseController.reset();
    }
  }

  Future<bool> _showImportConfirmationDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey.shade900
            : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          '⚠️ Attention',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'L\'importation va ajouter de nouvelles entrées à vos données existantes. Les entrées avec les mêmes identifiants seront mises à jour.\n\nVoulez-vous continuer ?',
          style: GoogleFonts.poppins(
            fontSize: 14,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Annuler',
              style: GoogleFonts.poppins(
                color: Colors.grey,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Continuer',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );

    return confirmed ?? false;
  }

  void _showCustomSnackBar(String message, bool success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              success ? Icons.check_circle : Icons.error,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: success ? Colors.green.shade600 : Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: Duration(seconds: success ? 3 : 5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0A0A0A)
          : const Color(0xFFF8FAFF),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
              const Color(0xFF1A1A2E),
              const Color(0xFF16213E),
              const Color(0xFF0F0F0F),
            ]
                : [
              const Color(0xFFE8F4FD),
              const Color(0xFFF0F8FF),
              const Color(0xFFFFFFFF),
            ],
          ),
        ),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // App Bar personnalisée
            SliverAppBar(
              expandedHeight: 120,
              floating: true,
              pinned: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.arrow_back,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              flexibleSpace: FlexibleSpaceBar(
                title: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    'Import / Export',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF2D3748),
                    ),
                  ),
                ),
                centerTitle: true,
              ),
            ),

            // Contenu principal
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // Section Description
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: _buildAnimatedCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          const Color(0xFF6366F1),
                                          const Color(0xFF8B5CF6),
                                        ],
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.sync_alt,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Gestion de tes données',
                                          style: GoogleFonts.poppins(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: isDark ? Colors.white : const Color(0xFF2D3748),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Exporte tes données pour les sauvegarder ou importe des données existantes.',
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                            height: 1.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Section Export
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: _buildAnimatedCard(
                          delay: 200,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle('📤 Exporter tes données'),
                              const SizedBox(height: 20),

                              // Bouton Export JSON
                              ScaleTransition(
                                scale: _loading ? _pulseAnimation : _scaleAnimation,
                                child: _buildActionButton(
                                  title: 'Export JSON',
                                  description: 'Sauvegarde complète avec tous les détails',
                                  icon: Icons.code,
                                  gradient: [
                                    const Color(0xFF6366F1),
                                    const Color(0xFF8B5CF6),
                                  ],
                                  onTap: _loading ? null : _exportJSON,
                                  isDark: isDark,
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Bouton Export CSV
                              ScaleTransition(
                                scale: _loading ? _pulseAnimation : _scaleAnimation,
                                child: _buildActionButton(
                                  title: 'Export CSV',
                                  description: 'Compatible Excel et Google Sheets',
                                  icon: Icons.table_chart,
                                  gradient: [
                                    const Color(0xFF10B981),
                                    const Color(0xFF059669),
                                  ],
                                  onTap: _loading ? null : _exportCSV,
                                  isDark: isDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Section Import
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: _buildAnimatedCard(
                          delay: 400,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle('📥 Importer des données'),
                              const SizedBox(height: 20),

                              // Bouton Import JSON
                              ScaleTransition(
                                scale: _loading ? _pulseAnimation : _scaleAnimation,
                                child: _buildActionButton(
                                  title: 'Import JSON',
                                  description: 'Restaure depuis un fichier JSON',
                                  icon: Icons.upload_file,
                                  gradient: [
                                    const Color(0xFFEF4444),
                                    const Color(0xFFDC2626),
                                  ],
                                  onTap: _loading ? null : () async {
                                    final confirmed = await _showImportConfirmationDialog();
                                    if (confirmed) {
                                      await _importJSON();
                                    }
                                  },
                                  isDark: isDark,
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Bouton Import CSV
                              ScaleTransition(
                                scale: _loading ? _pulseAnimation : _scaleAnimation,
                                child: _buildActionButton(
                                  title: 'Import CSV',
                                  description: 'Importe depuis un fichier CSV',
                                  icon: Icons.file_upload,
                                  gradient: [
                                    const Color(0xFFF59E0B),
                                    const Color(0xFFD97706),
                                  ],
                                  onTap: _loading ? null : () async {
                                    final confirmed = await _showImportConfirmationDialog();
                                    if (confirmed) {
                                      await _importCSV();
                                    }
                                  },
                                  isDark: isDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // État de chargement
                    if (_loading) ...[
                      SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: _buildAnimatedCard(
                            delay: 600,
                            child: Column(
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        const Color(0xFF6366F1),
                                        const Color(0xFF8B5CF6),
                                      ],
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.all(16),
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 3,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _loadingMessage ?? 'Traitement en cours...',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: isDark ? Colors.white : const Color(0xFF2D3748),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Veuillez patienter...',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],

                    // Section Aide
                    if (!_loading) ...[
                      SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: _buildAnimatedCard(
                            delay: 800,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionTitle('💡 Conseils d\'utilisation'),
                                const SizedBox(height: 16),
                                _buildTipItem(
                                  '📋',
                                  'Format des données',
                                  'Les fichiers CSV doivent contenir les colonnes: id, date, emotion, intensity',
                                  isDark,
                                ),
                                const SizedBox(height: 12),
                                _buildTipItem(
                                  '🔄',
                                  'Import sécurisé',
                                  'Les données existantes avec le même ID seront mises à jour',
                                  isDark,
                                ),
                                const SizedBox(height: 12),
                                _buildTipItem(
                                  '✅',
                                  'Validation',
                                  'Seules les entrées valides sont importées, les autres sont ignorées',
                                  isDark,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String title,
    required String description,
    required IconData icon,
    required List<Color> gradient,
    required VoidCallback? onTap,
    required bool isDark,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradient.map((c) => c.withOpacity(0.1)).toList(),
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: gradient.first.withOpacity(0.3),
            ),
            boxShadow: onTap != null ? [
              BoxShadow(
                color: gradient.first.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ] : [],
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradient),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null) ...[
                Icon(
                  Icons.arrow_forward_ios,
                  color: gradient.first,
                  size: 20,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipItem(String emoji, String title, String description, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.grey.shade800.withOpacity(0.5)
                : Colors.grey.shade100,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedCard({required Widget child, int delay = 0}) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey.shade900.withOpacity(0.6)
                    : Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey.shade700.withOpacity(0.5)
                      : Colors.grey.shade200,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.black.withOpacity(0.3)
                        : Colors.grey.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: child,
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : const Color(0xFF2D3748),
      ),
    );
  }
}