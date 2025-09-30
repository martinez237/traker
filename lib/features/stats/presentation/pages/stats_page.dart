import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/di/providers.dart';
import '../../../../domain/entities/mood_entry.dart';

class StatsPage extends ConsumerStatefulWidget {
  const StatsPage({super.key});

  @override
  ConsumerState<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends ConsumerState<StatsPage>
    with TickerProviderStateMixin {
  List<MoodEntry> _entries = [];
  bool _loading = true;
  int _days = 30;

  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _chartController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _chartAnimation;

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
    _chartController = AnimationController(
      duration: const Duration(milliseconds: 1200),
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

    _chartAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _chartController,
      curve: Curves.easeOutCubic,
    ));

    // Démarrer les animations
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 100), () {
      _slideController.forward();
    });
    Future.delayed(const Duration(milliseconds: 200), () {
      _scaleController.forward();
    });

    _load();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    _chartController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    _chartController.reset();

    final repo = ref.read(moodRepositoryProvider);
    final end = DateTime.now().toUtc();
    final start = end.subtract(Duration(days: _days - 1));
    final entries = await repo.getEntriesInRange(start, end);

    setState(() {
      _entries = entries;
      _loading = false;
    });

    if (!_loading) {
      _chartController.forward();
    }
  }

  double _avgIntensity() {
    if (_entries.isEmpty) return 0;
    return _entries.map((e) => e.intensity).average;
  }

  Map<String, int> _getEmotionStats() {
    final stats = <String, int>{};
    for (final entry in _entries) {
      stats[entry.emotion] = (stats[entry.emotion] ?? 0) + 1;
    }
    return stats;
  }

  Color _getEmotionColor(String emotion) {
    switch (emotion) {
      case 'happy':
        return const Color(0xFF4CAF50);
      case 'calm':
        return const Color(0xFF90CAF9);
      case 'energetic':
        return const Color(0xFFFFD54F);
      case 'stressed':
        return const Color(0xFFFF7043);
      case 'sad':
        return const Color(0xFF64B5F6);
      case 'tired':
        return const Color(0xFFA1887F);
      case 'anxious':
        return const Color(0xFFEF5350);
      default:
        return Colors.grey;
    }
  }

  String _getEmotionEmoji(String emotion) {
    switch (emotion) {
      case 'happy':
        return '😊';
      case 'calm':
        return '😌';
      case 'energetic':
        return '⚡';
      case 'stressed':
        return '😰';
      case 'sad':
        return '😢';
      case 'tired':
        return '😴';
      case 'anxious':
        return '😟';
      default:
        return '😐';
    }
  }

  List<FlSpot> _lineSpots() {
    final end = DateTime.now().toUtc();
    final start = end.subtract(Duration(days: _days - 1));
    final map = <int, double>{};
    for (int i = 0; i < _days; i++) {
      final day = DateTime.utc(start.year, start.month, start.day).add(Duration(days: i));
      final entry = _entries.firstWhereOrNull((e) =>
      e.date.year == day.year && e.date.month == day.month && e.date.day == day.day);
      map[i.toDouble().toInt()] = (entry?.intensity ?? 0).toDouble();
    }
    return map.entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final avg = _avgIntensity();
    final emotionStats = _getEmotionStats();

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
              flexibleSpace: FlexibleSpaceBar(
                title: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    'Mes Statistiques',
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
              child: _loading
                  ? const SizedBox(
                height: 400,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Analyse en cours...'),
                    ],
                  ),
                ),
              )
                  : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // Section Contrôles et Moyenne
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: _buildAnimatedCard(
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildSectionTitle('Période d\'analyse'),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF6366F1).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    child: SegmentedButton<int>(
                                      style: SegmentedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        foregroundColor: const Color(0xFF6366F1),
                                        selectedForegroundColor: Colors.white,
                                        selectedBackgroundColor: const Color(0xFF6366F1),
                                        side: BorderSide.none,
                                      ),
                                      segments: [
                                        ButtonSegment(
                                          value: 7,
                                          label: Text(
                                            '7 jours',
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        ButtonSegment(
                                          value: 30,
                                          label: Text(
                                            '30 jours',
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                      selected: {_days},
                                      onSelectionChanged: (s) {
                                        setState(() => _days = s.first);
                                        _load();
                                        // Animation de feedback
                                        _scaleController.reset();
                                        _scaleController.forward();
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildStatCard(
                                      'Entrées Total',
                                      '${_entries.length}',
                                      Icons.event_note,
                                      const Color(0xFF6366F1),
                                      isDark,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildStatCard(
                                      'Intensité Moyenne',
                                      avg > 0 ? avg.toStringAsFixed(1) : '0',
                                      Icons.trending_up,
                                      const Color(0xFF8B5CF6),
                                      isDark,
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

                    // Section Graphique d'Évolution
                    if (_entries.isNotEmpty) ...[
                      SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: _buildAnimatedCard(
                            delay: 200,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionTitle('Évolution de l\'humeur'),
                                const SizedBox(height: 24),
                                ScaleTransition(
                                  scale: _scaleAnimation,
                                  child: AnimatedBuilder(
                                    animation: _chartAnimation,
                                    builder: (context, child) {
                                      return SizedBox(
                                        height: 250,
                                        child: LineChart(
                                          LineChartData(
                                            minY: 0,
                                            maxY: 5,
                                            gridData: FlGridData(
                                              show: true,
                                              drawVerticalLine: true,
                                              horizontalInterval: 1,
                                              verticalInterval: _days > 7 ? 7 : 1,
                                              getDrawingHorizontalLine: (value) {
                                                return FlLine(
                                                  color: isDark
                                                      ? Colors.grey.shade700
                                                      : Colors.grey.shade300,
                                                  strokeWidth: 1,
                                                );
                                              },
                                              getDrawingVerticalLine: (value) {
                                                return FlLine(
                                                  color: isDark
                                                      ? Colors.grey.shade700
                                                      : Colors.grey.shade300,
                                                  strokeWidth: 1,
                                                );
                                              },
                                            ),
                                            titlesData: FlTitlesData(
                                              bottomTitles: AxisTitles(
                                                sideTitles: SideTitles(
                                                  showTitles: true,
                                                  reservedSize: 30,
                                                  interval: _days > 7 ? 7 : 1,
                                                  getTitlesWidget: (value, meta) {
                                                    return Text(
                                                      '${value.toInt() + 1}',
                                                      style: GoogleFonts.poppins(
                                                        fontSize: 12,
                                                        color: isDark
                                                            ? Colors.grey.shade400
                                                            : Colors.grey.shade600,
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                              leftTitles: AxisTitles(
                                                sideTitles: SideTitles(
                                                  showTitles: true,
                                                  reservedSize: 30,
                                                  interval: 1,
                                                  getTitlesWidget: (value, meta) {
                                                    return Text(
                                                      value.toInt().toString(),
                                                      style: GoogleFonts.poppins(
                                                        fontSize: 12,
                                                        color: isDark
                                                            ? Colors.grey.shade400
                                                            : Colors.grey.shade600,
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                              rightTitles: const AxisTitles(
                                                sideTitles: SideTitles(showTitles: false),
                                              ),
                                              topTitles: const AxisTitles(
                                                sideTitles: SideTitles(showTitles: false),
                                              ),
                                            ),
                                            borderData: FlBorderData(show: false),
                                            lineBarsData: [
                                              LineChartBarData(
                                                isCurved: true,
                                                curveSmoothness: 0.3,
                                                barWidth: 4,
                                                gradient: LinearGradient(
                                                  colors: [
                                                    const Color(0xFF6366F1),
                                                    const Color(0xFF8B5CF6),
                                                  ],
                                                ),
                                                belowBarData: BarAreaData(
                                                  show: true,
                                                  gradient: LinearGradient(
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                    colors: [
                                                      const Color(0xFF6366F1).withOpacity(0.3),
                                                      const Color(0xFF6366F1).withOpacity(0.1),
                                                      Colors.transparent,
                                                    ],
                                                  ),
                                                ),
                                                spots: _lineSpots()
                                                    .map((spot) => FlSpot(
                                                  spot.x,
                                                  spot.y * _chartAnimation.value,
                                                ))
                                                    .toList(),
                                                dotData: FlDotData(
                                                  show: true,
                                                  getDotPainter: (spot, percent, barData, index) {
                                                    return FlDotCirclePainter(
                                                      radius: 4,
                                                      color: Colors.white,
                                                      strokeWidth: 3,
                                                      strokeColor: const Color(0xFF6366F1),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],

                    // Section Répartition des Émotions
                    if (emotionStats.isNotEmpty) ...[
                      SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: _buildAnimatedCard(
                            delay: 400,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionTitle('Répartition des émotions'),
                                const SizedBox(height: 20),
                                ...emotionStats.entries.map((entry) {
                                  final percentage = (entry.value / _entries.length * 100);
                                  return TweenAnimationBuilder<double>(
                                    duration: const Duration(milliseconds: 800),
                                    tween: Tween(begin: 0.0, end: percentage),
                                    builder: (context, value, child) {
                                      return Container(
                                        margin: const EdgeInsets.only(bottom: 12),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color: _getEmotionColor(entry.key),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Center(
                                                child: Text(
                                                  _getEmotionEmoji(entry.key),
                                                  style: const TextStyle(fontSize: 16),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text(
                                                        entry.key.toUpperCase(),
                                                        style: GoogleFonts.poppins(
                                                          fontSize: 14,
                                                          fontWeight: FontWeight.w600,
                                                          color: isDark ? Colors.white : const Color(0xFF2D3748),
                                                        ),
                                                      ),
                                                      Text(
                                                        '${value.toStringAsFixed(1)}%',
                                                        style: GoogleFonts.poppins(
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.w500,
                                                          color: _getEmotionColor(entry.key),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 4),
                                                  LinearProgressIndicator(
                                                    value: value / 100,
                                                    backgroundColor: isDark
                                                        ? Colors.grey.shade800
                                                        : Colors.grey.shade200,
                                                    valueColor: AlwaysStoppedAnimation(
                                                      _getEmotionColor(entry.key),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                }).toList(),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],

                    // Section Insights
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: _buildAnimatedCard(
                          delay: 600,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle('Insights personnalisés'),
                              const SizedBox(height: 16),
                              ..._buildInsights().asMap().entries.map((entry) {
                                return TweenAnimationBuilder<double>(
                                  duration: Duration(milliseconds: 400 + (entry.key * 200)),
                                  tween: Tween(begin: 0.0, end: 1.0),
                                  builder: (context, value, child) {
                                    return Transform.translate(
                                      offset: Offset(0, 20 * (1 - value)),
                                      child: Opacity(
                                        opacity: value,
                                        child: Container(
                                          margin: const EdgeInsets.only(bottom: 12),
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                const Color(0xFF6366F1).withOpacity(0.1),
                                                const Color(0xFF8B5CF6).withOpacity(0.1),
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(
                                              color: const Color(0xFF6366F1).withOpacity(0.3),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 40,
                                                height: 40,
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
                                                  Icons.lightbulb,
                                                  color: Colors.white,
                                                  size: 20,
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              Expanded(
                                                child: Text(
                                                  entry.value,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                    color: isDark ? Colors.white : const Color(0xFF2D3748),
                                                    height: 1.4,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      ),
                    ),

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

  Widget _buildStatCard(String title, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF2D3748),
            ),
          ),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
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

  List<String> _buildInsights() {
    if (_entries.length < 7) {
      return ['📊 Enregistre plus d\'humeurs pour obtenir des analyses personnalisées.'];
    }

    final weekdays = _entries
        .map((e) => (e.date.weekday, e.intensity))
        .groupListsBy((p) => p.$1)
        .map((k, v) => MapEntry(k, v.map((e) => e.$2).average));

    final weekendAvg = [6, 7].map((d) => weekdays[d] ?? 0).average;
    final weekdayAvg = [1, 2, 3, 4, 5].map((d) => weekdays[d] ?? 0).average;
    final delta = weekendAvg - weekdayAvg;

    final List<String> insights = [];

    if (delta > 0.3) {
      insights.add('🎉 Tu es généralement plus heureux le weekend (+${delta.toStringAsFixed(1)} points).');
    } else if (delta < -0.3) {
      insights.add('🤔 Ton humeur tend à baisser le weekend (${delta.toStringAsFixed(1)} points).');
    } else {
      insights.add('⚖️ Ton humeur reste stable entre la semaine et le weekend.');
    }

    final mostCommonEmotion = _getEmotionStats().entries
        .reduce((a, b) => a.value > b.value ? a : b);

    insights.add('${_getEmotionEmoji(mostCommonEmotion.key)} Ton émotion dominante est "${mostCommonEmotion.key}" (${(mostCommonEmotion.value / _entries.length * 100).toStringAsFixed(1)}%).');

    if (_avgIntensity() >= 4) {
      insights.add('✨ Tu affiches une excellente stabilité émotionnelle !');
    } else if (_avgIntensity() <= 2) {
      insights.add('💙 Prends soin de toi, tes émotions méritent attention.');
    }

    return insights;
  }
}