import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late AnimationController _progressController;
  late AnimationController _textAnimationController;
  late AnimationController _particleController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<double> _particleAnimation;

  List<String> loadingTexts = [
    'Initialisation du système...',
    'Chargement des modules d\'émotion...',
    'Configuration de l\'interface...',
    'Préparation de ton espace personnel...',
    'Synchronisation des données...',
    'Optimisation des performances...',
    'Finalisation du chargement...',
    'Prêt à commencer !',
  ];

  int currentTextIndex = 0;

  @override
  void initState() {
    super.initState();

    // Initialiser les contrôleurs d'animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );
    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    );
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 8000), // 8 secondes pour la barre de progression
      vsync: this,
    );
    _textAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 6000),
      vsync: this,
    );

    // Créer les animations
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.2,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.85,
      end: 1.15,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _rotateAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotateController,
      curve: Curves.linear,
    ));

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));

    _textFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textAnimationController,
      curve: Curves.easeInOut,
    ));

    _particleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _particleController,
      curve: Curves.easeInOut,
    ));

    // Séquence d'animations
    _startAnimationSequence();
  }

  void _startAnimationSequence() async {
    // Phase 1: Animation du logo (0-1.2s)
    _scaleController.forward();

    // Phase 2: Animation du fade in (0.4s-2.2s)
    await Future.delayed(const Duration(milliseconds: 400));
    _fadeController.forward();

    // Phase 3: Animation du slide up (0.8s-2.3s)
    await Future.delayed(const Duration(milliseconds: 400));
    _slideController.forward();

    // Phase 4: Animations continues (1s-8s)
    await Future.delayed(const Duration(milliseconds: 200));
    _pulseController.repeat(reverse: true);
    _rotateController.repeat();
    _progressController.forward();
    _particleController.repeat();

    // Phase 5: Animation des textes de chargement
    _startTextAnimation();

    // Phase 6: Délai total de 8 secondes exactement
    await Future.delayed(const Duration(milliseconds: 8000));

    // Phase 7: Animation de sortie et navigation
    await _exitAnimation();

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const MainPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  void _startTextAnimation() async {
    // Chaque texte dure 1 seconde, 8 textes pour 8 secondes
    for (int i = 0; i < loadingTexts.length; i++) {
      if (!mounted) break;

      setState(() {
        currentTextIndex = i;
      });

      _textAnimationController.reset();
      _textAnimationController.forward();

      await Future.delayed(const Duration(milliseconds: 1000)); // 1 seconde par texte
    }
  }

  Future<void> _exitAnimation() async {
    // Animation de sortie plus lente et élégante
    await Future.wait([
      _fadeController.reverse(),
      _scaleController.reverse(),
    ]);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    _rotateController.dispose();
    _progressController.dispose();
    _textAnimationController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF667eea),
                const Color(0xFF764ba2),
                const Color(0xFFf093fb),
                const Color(0xFFa855f7),
              ],
              stops: const [0.0, 0.3, 0.7, 1.0],
            ),
          ),
          child: Stack(
            children: [
              // Particules d'arrière-plan animées avec plus d'effets
              ...List.generate(40, (index) => _buildFloatingParticle(index)),

              // Cercles d'arrière-plan animés
              ...List.generate(3, (index) => _buildAnimatedCircle(index)),

              // Contenu principal
              Center(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo principal avec animations améliorées
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _pulseAnimation.value,
                              child: Container(
                                width: 160,
                                height: 160,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      Colors.white.withOpacity(0.5),
                                      Colors.white.withOpacity(0.3),
                                      Colors.white.withOpacity(0.1),
                                      Colors.transparent,
                                    ],
                                    stops: const [0.0, 0.5, 0.8, 1.0],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.4),
                                      blurRadius: 50,
                                      spreadRadius: 15,
                                    ),
                                    BoxShadow(
                                      color: const Color(0xFF764ba2).withOpacity(0.4),
                                      blurRadius: 30,
                                      spreadRadius: 8,
                                    ),
                                    BoxShadow(
                                      color: const Color(0xFFf093fb).withOpacity(0.3),
                                      blurRadius: 60,
                                      spreadRadius: 20,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.emoji_emotions,
                                  size: 80,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 60),

                      // Titre principal amélioré
                      SlideTransition(
                        position: _slideAnimation,
                        child: Text(
                          'Mood Tracker',
                          style: GoogleFonts.poppins(
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 4,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 6),
                              ),
                              Shadow(
                                color: const Color(0xFF764ba2).withOpacity(0.6),
                                blurRadius: 30,
                                offset: const Offset(0, 12),
                              ),
                              Shadow(
                                color: const Color(0xFFf093fb).withOpacity(0.4),
                                blurRadius: 40,
                                offset: const Offset(0, 18),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      // Sous-titre
                      SlideTransition(
                        position: _slideAnimation,
                        child: Text(
                          'Journal d\'humeur moderne & intelligent',
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withOpacity(0.95),
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),

                      const SizedBox(height: 80),

                      // Barre de progression améliorée avec animation plus lente
                      SlideTransition(
                        position: _slideAnimation,
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.75,
                          height: 10,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.white.withOpacity(0.25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: AnimatedBuilder(
                            animation: _progressAnimation,
                            builder: (context, child) {
                              return Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white,
                                      Colors.white.withOpacity(0.9),
                                      const Color(0xFFf093fb),
                                      const Color(0xFFa855f7),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.6),
                                      blurRadius: 15,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                width: MediaQuery.of(context).size.width * 0.75 * _progressAnimation.value,
                                height: 10,
                              );
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Indicateur de chargement rotatif amélioré
                      SlideTransition(
                        position: _slideAnimation,
                        child: AnimatedBuilder(
                          animation: _rotateController,
                          builder: (context, child) {
                            return Transform.rotate(
                              angle: _rotateAnimation.value * 2 * 3.14159,
                              child: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 5,
                                  ),
                                ),
                                child: Container(
                                  margin: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: SweepGradient(
                                      colors: [
                                        Colors.white,
                                        Colors.white.withOpacity(0.8),
                                        Colors.white.withOpacity(0.3),
                                        Colors.transparent,
                                        Colors.transparent,
                                      ],
                                      stops: const [0.0, 0.2, 0.4, 0.7, 1.0],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 50),

                      // Texte de chargement animé
                      SlideTransition(
                        position: _slideAnimation,
                        child: AnimatedBuilder(
                          animation: _textFadeAnimation,
                          builder: (context, child) {
                            return FadeTransition(
                              opacity: _textFadeAnimation,
                              child: Text(
                                currentTextIndex < loadingTexts.length
                                    ? loadingTexts[currentTextIndex]
                                    : 'Prêt à commencer !',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white.withOpacity(0.95),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 50),

                      // Points de chargement animés améliorés
                      SlideTransition(
                        position: _slideAnimation,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(7, (index) {
                            return AnimatedBuilder(
                              animation: _pulseController,
                              builder: (context, child) {
                                final delay = index * 0.15;
                                final animationValue = (_pulseController.value + delay) % 1.0;
                                final scale = (animationValue < 0.5)
                                    ? 0.4 + (animationValue * 1.2)
                                    : 1.6 - (animationValue * 1.2);

                                return Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 6),
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withOpacity(scale * 0.9),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.white.withOpacity(0.4),
                                        blurRadius: scale * 12,
                                        spreadRadius: scale * 3,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Pourcentage de progression avec animation plus lente
              Positioned(
                bottom: 140,
                left: 0,
                right: 0,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: AnimatedBuilder(
                    animation: _progressAnimation,
                    builder: (context, child) {
                      return Center(
                        child: Text(
                          '${(_progressAnimation.value * 100).toInt()}%',
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Colors.white.withOpacity(0.95),
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Version en bas
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Center(
                    child: Text(
                      'Version 1.0.0 • Mood Tracker Pro • Premium Experience',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingParticle(int index) {
    final random = (index * 29) % 100;
    final size = 1.0 + (random % 8);
    final left = (random % 130) * 3.0;
    final animationDelay = (random % 10) * 300;
    final duration = 5000 + (random % 4000);

    return AnimatedBuilder(
      animation: _particleAnimation,
      builder: (context, child) {
        return Positioned(
          left: left,
          top: 30 + (random % 600).toDouble(),
          child: TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: duration),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(
                  (random % 2 == 0 ? 1 : -1) * value * 80,
                  -value * 400,
                ),
                child: Opacity(
                  opacity: (1 - value) * 0.9,
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withOpacity(0.8),
                          Colors.white.withOpacity(0.4),
                          Colors.white.withOpacity(0.1),
                          Colors.transparent,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.4),
                          blurRadius: size * 3,
                          spreadRadius: size,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            onEnd: () {
              if (mounted) {
                Future.delayed(Duration(milliseconds: animationDelay), () {
                  if (mounted) setState(() {});
                });
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildAnimatedCircle(int index) {
    final sizes = [200.0, 150.0, 100.0];
    final delays = [0, 1000, 2000];
    final opacities = [0.1, 0.15, 0.2];

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Positioned(
          top: MediaQuery.of(context).size.height * 0.3 + (index * 50),
          left: MediaQuery.of(context).size.width * 0.5 - (sizes[index] / 2),
          child: Container(
            width: sizes[index] * (0.8 + (_pulseAnimation.value * 0.4)),
            height: sizes[index] * (0.8 + (_pulseAnimation.value * 0.4)),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(opacities[index]),
                width: 2,
              ),
            ),
          ),
        );
      },
    );
  }
}

// Page principale exemple améliorée
class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mood Tracker',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF667eea).withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.emoji_emotions,
                size: 100,
                color: Color(0xFF667eea),
              ),
              const SizedBox(height: 30),
              Text(
                'Bienvenue dans Mood Tracker !',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF667eea),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Commencez à suivre votre humeur quotidienne et découvrez vos patterns émotionnels',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  // Action pour commencer
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF667eea),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text(
                  'Commencer mon journal',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}