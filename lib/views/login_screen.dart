import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import 'main_screen.dart';
import '../screens/admin_dashboard_screen.dart'; 
import '../main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  void _showSnackBar(String message, {bool success = false}) {
    rootScaffoldMessengerKey.currentState
      ?..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor:
              success ? const Color(0xFFFF8FAB) : Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
  }
  
  Future<void> _showLoginDialog({
    required String title,
    required String message,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          message,
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              "OK",
              style: GoogleFonts.poppins(
                color: const Color(0xFFFF8FAB),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar("Email dan password wajib diisi!");
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      _showSnackBar("Format email belum valid!");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final watch = Stopwatch()..start();
      final userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      print(userQuery.docs.length);

      if (userQuery.docs.isEmpty) {
        setState(() => _isLoading = false);
        _showSnackBar(
            "Email belum terdaftar. Silakan daftar akun terlebih dahulu.");
        return;
      }
      // 1. LOGIN KE FIREBASE AUTH
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print("Firebase Auth : ${watch.elapsedMilliseconds} ms");

      // 2. AMBIL DATA DARI FIRESTORE
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();
      print("Firestore : ${watch.elapsedMilliseconds} ms");

      if (userDoc.exists) {
        String role = (userDoc['role'] ?? 'pengguna').toString().toLowerCase();

        if (mounted) {
          if (role == 'admin') {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
              (route) => false,
            );
          } else {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const MainScreen()),
              (route) => false,
            );
          }
        }
      } else {
        _showSnackBar("Data pengguna tidak ditemukan di database.");
      }
    } on FirebaseAuthException catch (e) {
      String title = "Login Gagal";
      String message = "Terjadi kesalahan saat login.";

      switch (e.code) {
        case 'invalid-email':
          message = "Format email tidak valid.";
          break;

        case 'invalid-credential':
          message =
              "Email atau password salah.\n"
              "Pastikan data yang dimasukkan benar.";
          break;

        case 'user-not-found':
          message =
              "Email belum terdaftar.\n"
              "Silakan buat akun terlebih dahulu.";
          break;

        case 'wrong-password':
          message =
              "Password yang dimasukkan salah.";
          break;

        case 'too-many-requests':
          message =
              "Terlalu banyak percobaan login.\n"
              "Coba lagi nanti.";
          break;

        default:
          message = e.message ?? "Login gagal.";
      }

      if (mounted) {
        await _showLoginDialog(
          title: title,
          message: message,
        );
      }

    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);

    try {
      final GoogleSignInAccount? googleUser =
          await GoogleSignIn().signIn();

      if (googleUser == null) {
        _showSnackBar("Login Google dibatalkan.");
        return;
      }

      final email = googleUser.email;

      final query = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {

        await GoogleSignIn().signOut();

        if (mounted) {
          await _showLoginDialog(
            title: "Akun Belum Terdaftar",
            message:
                "Akun Google ini belum terdaftar.\n"
                "Silakan daftar terlebih dahulu.",
          );
        }

        return;
      }

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

      final user = userCredential.user;

      if (user == null) {
        _showSnackBar("Data Google tidak ditemukan.");
        return;
      }

      final userDoc = query.docs.first;

      final role =
          (userDoc['role'] ?? 'pengguna').toString().toLowerCase();

      if (!mounted) return;

      if (role == 'admin') {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const AdminDashboardScreen(),
          ),
          (_) => false,
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const MainScreen(),
          ),
          (_) => false,
        );
      }

    } on FirebaseAuthException catch (e) {
      _showSnackBar(e.message ?? "Login Google gagal.");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF140F1F),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF140F1F),
              Color(0xFF2B164A),
              Color(0xFF4A1D4F),
              Color(0xFF1A1533),
            ],
          ),
        ),
        child: Stack(
          children: [
            const FloatingBubble(
              size: 180,
              color: Color(0xFFFF8FAB),
              top: -40,
              left: -30,
            ),
            const FloatingBubble(
              size: 140,
              color: Color(0xFFD8C4FF),
              top: 120,
              left: 280,
            ),
            const FloatingBubble(
              size: 120,
              color: Color(0xFFFFB7D5),
              top: 620,
              left: -20,
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: const Color(0xFFD8C4FF).withOpacity(0.25),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF8FAB).withOpacity(0.14),
                        blurRadius: 30,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFFFB7D5),
                              Color(0xFFD8C4FF),
                            ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF8FAB).withOpacity(0.25),
                              blurRadius: 22,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.auto_awesome,
                          size: 42,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Knit Nest",
                        style: GoogleFonts.dmSerifDisplay(
                          fontSize: 38,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Crochet, create & track your cozy journey ✿",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 32),

                      TextField(
                        controller: _emailController,
                        style: GoogleFonts.poppins(color: Colors.white),
                        decoration: _inputDecoration(
                          hint: "Email",
                          icon: Icons.email_outlined,
                        ),
                      ),

                      const SizedBox(height: 16),

                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: GoogleFonts.poppins(color: Colors.white),
                        decoration: _inputDecoration(
                          hint: "Password",
                          icon: Icons.lock_outline,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.white60,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ForgotPasswordScreen(),
                              ),
                            );
                          },
                          child: Text(
                            "Forgot Password?",
                            style: GoogleFonts.poppins(
                              color: const Color(0xFFFFB7D5),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: const Color(0xFFFF8FAB),
                            disabledBackgroundColor:
                                const Color(0xFFFF8FAB).withOpacity(0.45),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  "Masuk",
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton.icon(
                          onPressed: _isLoading ? null : _handleGoogleLogin,
                          icon: const Icon(
                            Icons.g_mobiledata,
                            size: 30,
                            color: Colors.white,
                          ),
                          label: Text(
                            "Masuk dengan Google",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.08),
                            side: BorderSide(
                              color: const Color(0xFFD8C4FF).withOpacity(0.25),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                            children: [
                              const TextSpan(text: "Belum punya akun? "),
                              TextSpan(
                                text: "Daftar di sini",
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFFFFB7D5),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(color: Colors.white54),
      filled: true,
      fillColor: Colors.white.withOpacity(0.08),
      prefixIcon: Icon(icon, color: const Color(0xFFD8C4FF)),
      suffixIcon: suffixIcon,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: const Color(0xFFD8C4FF).withOpacity(0.22),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: Color(0xFFFF8FAB),
          width: 2,
        ),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
    );
  }
}

// POSISI CLASS FLOATINGBUBBLE 
class FloatingBubble extends StatefulWidget {
  final double size;
  final Color color;
  final double top;
  final double left;

  const FloatingBubble({
    super.key,
    required this.size,
    required this.color,
    required this.top,
    required this.left,
  });

  @override
  State<FloatingBubble> createState() => _FloatingBubbleState();
}

class _FloatingBubbleState extends State<FloatingBubble> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: -8,
      end: 8,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, child) {
        return Positioned(
          top: widget.top + _animation.value,
          left: widget.left,
          child: child!,
        );
      },
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: widget.color.withOpacity(0.28),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}