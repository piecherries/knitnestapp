import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'login_screen.dart';
import '../main.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController(); 
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isRegisterLoading = false;
  bool _isGoogleLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  void _showSnackBar(String message, {bool success = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
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

  Future<void> _handleRegister() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    if (name.isEmpty) {
      _showSnackBar("Nama lengkap wajib diisi!");
      return;
    }
    if (email.isEmpty) {
      _showSnackBar("Email wajib diisi!");
      return;
    }
    if (password.isEmpty) {
      _showSnackBar("Password wajib diisi!");
      return;
    }
    if (confirmPassword.isEmpty) {
      _showSnackBar("Konfirmasi password wajib diisi!");
      return;
    }
    if (password != confirmPassword) {
      _showSnackBar("Password dan konfirmasi password tidak sama!");
      return;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      _showSnackBar("Format email tidak valid!");
      return;
    }
    if (password.length < 8) {
      _showSnackBar("Password minimal harus 8 karakter!");
      return;
    }
    if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$').hasMatch(password)) {
      _showSnackBar("Password harus kombinasi huruf dan angka!");
      return;
    }

    setState(() => _isRegisterLoading = true);

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'uid': userCredential.user!.uid,
        'name': name,
        'email': email,
        'role': 'pengguna',
        'coins': 10,
        'favoriteModules': [],
        'createdAt': FieldValue.serverTimestamp(),
      });
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text("Pendaftaran Berhasil"),
          content: const Text(
            "Akun berhasil dibuat.\nSilakan login.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginScreen(),
                  ),
                  (route) => false,
                );
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
      
    } on FirebaseAuthException catch (e) {
      String message = "Terjadi kesalahan.";
      if (e.code == 'email-already-in-use') {
        message = "Email ini sudah terdaftar. Silakan login.";
      } else if (e.code == 'weak-password') {
        message = "Password terlalu lemah.";
      } else if (e.code == 'invalid-email') {
        message = "Format email tidak valid.";
      }
      _showSnackBar(message);
    } catch (e) {
      _showSnackBar("Terjadi error: ${e.toString()}");
    } finally {
      if (mounted) {
        setState(() => _isRegisterLoading = false);
      }
    }
  }

  Future<void> _handleGoogleRegister() async {
    setState(() => _isGoogleLoading = true);
    try {
      await GoogleSignIn().signOut();
      await FirebaseAuth.instance.signOut();
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        if (mounted) setState(() => _isGoogleLoading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      final user = userCredential.user;
      if (user == null) return;

      final query = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: user.email)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        _showSnackBar("Akun Google ini sudah terdaftar. Silakan login.");
        await FirebaseAuth.instance.signOut();
        await GoogleSignIn().signOut();
        return;
      }

      final userRef =
          FirebaseFirestore.instance.collection('users').doc(user.uid);

      await userRef.set({
        'uid': user.uid,
        'name': user.displayName ?? '',
        'email': user.email ?? '',
        'photoUrl': user.photoURL ?? '',
        'role': 'pengguna',
        'coins': 10,
        'favoriteModules': [],
        'createdAt': FieldValue.serverTimestamp(),
      });
      print(mounted);

      print("Firestore berhasil");

      if (!mounted) return;

      print("Show snackbar");

      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();

      if (!mounted) return;

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text("Pendaftaran Berhasil"),
          content: const Text(
            "Akun Google berhasil dibuat.\nSilakan login.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginScreen(),
                  ),
                  (route) => false,
                );
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } catch (e) {
      _showSnackBar("Daftar Google gagal: $e");
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  // UI 
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
              size: 170,
              color: Color(0xFFFF8FAB),
              top: -30,
              left: -20,
            ),
            const FloatingBubble(
              size: 120,
              color: Color(0xFFD8C4FF),
              top: 150,
              left: 280,
            ),
            const FloatingBubble(
              size: 100,
              color: Color(0xFFFFB7D5),
              top: 650,
              left: -10,
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: SingleChildScrollView(
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
                        Align(
                          alignment: Alignment.topLeft,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                ),
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

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

                        const SizedBox(height: 16),

                        Text(
                          "Join Knit Nest ✿",
                          style: GoogleFonts.dmSerifDisplay(
                            fontSize: 34,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          "Start your crochet journey today",
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                          ),
                        ),

                        const SizedBox(height: 30),

                        TextField(
                          controller: _nameController,
                          style: GoogleFonts.poppins(color: Colors.white),
                          decoration: _inputDecoration(
                            hint: "Nama lengkap",
                            icon: Icons.person_outline,
                          ),
                        ),

                        const SizedBox(height: 16),

                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
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
                            helper: "Minimal 8 karakter, huruf & angka",
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

                        const SizedBox(height: 16),

                        TextField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          style: GoogleFonts.poppins(color: Colors.white),
                          decoration: _inputDecoration(
                            hint: "Konfirmasi Password",
                            icon: Icons.lock_outline,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.white60,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
                                });
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 26),

                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isGoogleLoading ? null : _handleRegister,
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: const Color(0xFFFF8FAB),
                              disabledBackgroundColor:
                                  const Color(0xFFFF8FAB).withOpacity(0.45),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: _isGoogleLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    "Daftar Akun",
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
                            onPressed:
                                _isGoogleLoading ? null : _handleGoogleRegister,
                            icon: const Icon(
                              Icons.g_mobiledata,
                              size: 30,
                              color: Colors.white,
                            ),
                            label: Text(
                              "Daftar dengan Google",
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
                          onTap: () => Navigator.pop(context),
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                              children: [
                                const TextSpan(text: "Sudah punya akun? "),
                                TextSpan(
                                  text: "Login di sini",
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
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    String? helper,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      helperText: helper,
      hintStyle: GoogleFonts.poppins(color: Colors.white54),
      helperStyle: GoogleFonts.poppins(
        color: Colors.white38,
        fontSize: 11,
      ),
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