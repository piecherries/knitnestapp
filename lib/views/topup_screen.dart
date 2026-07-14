import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TopUpScreen extends StatelessWidget {
  const TopUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF8E9775); // Sage Green
    const Color darkGreen = Color(0xFF5A6344);    // Deep Forest

    // Data paket koin dengan Icon unik buat tiap tier
    final List<Map<String, dynamic>> coinPackages = [
      {"coins": 50, "price": "Rp 5.000", "label": "Starter Kit", "icon": Icons.eco_rounded},
      {"coins": 150, "price": "Rp 12.000", "label": "Crafter Pack", "icon": Icons.local_mall_rounded},
      {"coins": 500, "price": "Rp 35.000", "label": "Master Knitter", "icon": Icons.auto_awesome_rounded},
      {"coins": 1200, "price": "Rp 75.000", "label": "Legendary Yarn", "icon": Icons.workspace_premium_rounded},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F1),
      body: CustomScrollView(
        slivers: [
          // 1. Gacor Header dengan Gradasi & Icon Floating
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: darkGreen,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: const Text("Isi Ulang Koin 🪙", 
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryGreen, darkGreen],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -20, top: 40,
                      child: Icon(Icons.stars_rounded, size: 120, color: Colors.white.withOpacity(0.1)),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 2. Konten Pilihan Paket
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Pilih Paket Rajutmu 🧶", 
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkGreen)),
                  const Text("Dapatkan koin untuk akses pola & materi eksklusif.", 
                    style: TextStyle(fontSize: 13, color: Colors.grey)),
                  const SizedBox(height: 25),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 20, // Jarak antar card diperlebar
                mainAxisSpacing: 20,  // Jarak atas-bawah diperlebar
                childAspectRatio: 0.75, // Disesuaikan biar tetap pas dan nggak overflow
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildCoinCard(context, coinPackages[index]),
                childCount: coinPackages.length,
              ),
            ),
          ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 30)),
        ],
      ),
    );
  }

  Widget _buildCoinCard(BuildContext context, Map<String, dynamic> package) {
    const Color darkGreen = Color(0xFF5A6344);
    const Color primaryGreen = Color(0xFF8E9775);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: darkGreen.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showPaymentSimulation(context, package['coins'], package['price']),
          borderRadius: BorderRadius.circular(25),
          child: Padding(
            padding: const EdgeInsets.all(12.0), // Padding diperkecil dari 15 ke 12
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8), // Circle icon dikecilkan
                  decoration: BoxDecoration(
                    color: const Color(0xFF8E9775).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(package['icon'], size: 28, color: const Color(0xFF8E9775)), // Ukuran icon dikecilkan
                ),
                const SizedBox(height: 10),
                Text("${package['coins']} Koin", 
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF5A6344))), // Font dikecilkan
                Text(package['label'], 
                  style: const TextStyle(color: Colors.grey, fontSize: 10)),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF8E9775), Color(0xFF9DAD7F)]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      package['price'],
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPaymentSimulation(BuildContext context, int coins, String price) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, // Bikin transparan biar bisa pake dekorasi sendiri
      builder: (context) => Container(
        padding: const EdgeInsets.all(30.0),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle Bar
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 25),
            const Text("Konfirmasi Pembayaran 💳", 
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF5A6344))),
            const SizedBox(height: 15),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(color: Colors.black87, fontSize: 15),
                children: [
                  const TextSpan(text: "Kamu akan melakukan pembelian paket koin sebanyak "),
                  TextSpan(text: "$coins Koin", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF8E9775))),
                  const TextSpan(text: " seharga "),
                  TextSpan(text: price, style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5A6344),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  elevation: 0,
                ),
                onPressed: () async {
                  // LOGIKA FIREBASE: Langsung update saldo koin user
                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    var userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
                    await FirebaseFirestore.instance.runTransaction((transaction) async {
                      DocumentSnapshot snapshot = await transaction.get(userRef);
                      if (snapshot.exists) {
                        int currentCoins = (snapshot.data() as Map<String, dynamic>)['coins'] ?? 0;
                        transaction.update(userRef, {'coins': currentCoins + coins});
                      }
                    });
                  }

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Berhasil membeli $coins Koin! Selamat merajut ✨"),
                      backgroundColor: const Color(0xFF8E9775),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                },
                child: const Text("Konfirmasi & Bayar", 
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}