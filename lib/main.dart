import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'views/login_screen.dart'; 
import 'views/main_screen.dart'; 
import 'screens/admin_dashboard_screen.dart'; 
import 'views/welcome_screen.dart';
// import 'views/module_detail_screen.dart';

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); 
  runApp(const KnitNestApp());
}

class KnitNestApp extends StatelessWidget {
  const KnitNestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Knit Nest',
      scaffoldMessengerKey: rootScaffoldMessengerKey, 
      theme: ThemeData(primarySwatch: Colors.purple),
      home: const WelcomeScreen(), // atau AuthWrapper()
    );
  }
}

// Widget Perantara untuk Cek Status & Role
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          final user = snapshot.data!;

          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                return const LoginScreen();
              }

              final data = userSnapshot.data!.data() as Map<String, dynamic>;
              final role = (data['role'] ?? 'pengguna').toString().toLowerCase();

              if (role == 'admin') {
                return const AdminDashboardScreen();
              }

              return const MainScreen();
            },
          );
        }

        return const LoginScreen();
      },
    );
  }
}

