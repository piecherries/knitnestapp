import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _rotateController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _scaleAnimation = Tween<double>(
      begin: 0.65,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.elasticOut,
      ),
    );

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_logoController);

    _logoController.forward();

    Timer(const Duration(seconds: 5), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const AuthWrapper(),
        ),
      );
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFF8F2),
              Color(0xFFFFE4EC),
              Color(0xFFE7D8FF),
            ],
          ),
        ),
        child: Stack(
          children: [
            const _Bubble(
              size: 180,
              top: -40,
              left: -30,
              color: Color(0xFFFFB7D5),
            ),

            const _Bubble(
              size: 120,
              top: 120,
              left: 280,
              color: Color(0xFFD8C4FF),
            ),

            const _Bubble(
              size: 110,
              top: 650,
              left: -20,
              color: Color(0xFFB7D3B0),
            ),

            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RotationTransition(
                      turns: _rotateController,
                      child: const Icon(
                        Icons.auto_awesome,
                        size: 26,
                        color: Color(0xFF8E6CEF),
                      ),
                    ),

                    const SizedBox(height: 16),

                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFFFB7D5),
                              Color(0xFFD8C4FF),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.purple.withOpacity(0.2),
                              blurRadius: 28,
                              offset: const Offset(0, 14),
                            )
                          ],
                        ),
                        child: const Icon(
                          Icons.spa_rounded,
                          size: 64,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    Text(
                      "Knit Nest",
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 48,
                        color: const Color(0xFF4A3F35),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      "Crochet • Create • Cozy ✿",
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: Colors.grey.shade700,
                      ),
                    ),

                    const SizedBox(height: 36),

                    const SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: Color(0xFF8E6CEF),
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
}

class _Bubble extends StatefulWidget {
  final double size;
  final double top;
  final double left;
  final Color color;

  const _Bubble({
    required this.size,
    required this.top,
    required this.left,
    required this.color,
  });

  @override
  State<_Bubble> createState() => _BubbleState();
}

class _BubbleState extends State<_Bubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, child) {
        return Positioned(
          top: widget.top + sin(_controller.value * pi * 2) * 12,
          left: widget.left,
          child: child!,
        );
      },
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: widget.color.withOpacity(0.25),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}