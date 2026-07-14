import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../views/login_screen.dart';

const darkBg = Color(0xFF140F1F);
const darkPurple = Color(0xFF2B164A);
const funkyPink = Color(0xFFFF8FAB);
const softPink = Color(0xFFFFB7D5);
const softLilac = Color(0xFFD8C4FF);
const cream = Color(0xFFFFF8F2);
const mint = Color(0xFF65B891);
const gold = Color(0xFFFFB703);

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: softLilac),
      hintStyle: const TextStyle(color: Colors.white54),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: softLilac.withOpacity(.3)),
      ),

      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: funkyPink, width: 2),
      ),
    );
  }

  void _showAddModulDialog(BuildContext context) {
    final titleController = TextEditingController();
    final priceController = TextEditingController();
    final idController = TextEditingController();
    final descController = TextEditingController();
    String selectedLevel = "Beginner";
    // final durationController = TextEditingController();
    final videoController = TextEditingController();
    final imageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: darkPurple,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          "Tambah Modul Baru",
          style: TextStyle(
            color: cream,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: idController,
                style: const TextStyle(
                  color: cream,
                  fontSize: 16,
                ),
                cursorColor: funkyPink,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration("ID Modul"),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                style: const TextStyle(
                  color: cream,
                  fontSize: 16,
                ),
                cursorColor: funkyPink,
                decoration: _inputDecoration("Judul Modul"),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: priceController,
                style: const TextStyle(
                  color: cream,
                  fontSize: 16,
                ),
                cursorColor: funkyPink,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration("Harga (Koin)"),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descController,
                style: const TextStyle(
                  color: cream,
                  fontSize: 16,
                ),
                cursorColor: funkyPink,
                decoration: _inputDecoration("Deskripsi Materi"),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                style: const TextStyle(
                  color: funkyPink,
                  fontSize: 16,
                ),
                value: selectedLevel,
                items: const [
                  DropdownMenuItem(value: "Beginner", child: Text("Beginner")),
                  DropdownMenuItem(value: "Intermediate", child: Text("Intermediate")),
                  DropdownMenuItem(value: "Advanced", child: Text("Advanced")),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedLevel = value!;
                  });
                },
                decoration: _inputDecoration("Level"),
              ),

              // const SizedBox(height: 16),
              // TextField(
              //   controller: durationController,
              //   style: const TextStyle(color: cream),
              //   cursorColor: funkyPink,
              //   decoration: _inputDecoration("Durasi (contoh: 15 menit)"),
              // ),

              const SizedBox(height: 16),
              TextField(
                controller: videoController,
                style: const TextStyle(color: cream),
                cursorColor: funkyPink,
                decoration: _inputDecoration("Link YouTube"),
              ),

              // const SizedBox(height: 16),
              // TextField(
              //   controller: imageController,
              //   style: const TextStyle(color: cream),
              //   cursorColor: funkyPink,
              //   decoration: _inputDecoration("Link Gambar"),
              // ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Batal",
              style: TextStyle(color: softLilac),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: funkyPink,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              await FirebaseFirestore.instance.collection('modules').add({
                'id': int.parse(idController.text),
                'title': titleController.text,
                'description': descController.text,
                'price': int.parse(priceController.text),

                'level': selectedLevel,
                // 'duration': durationController.text,
                'videoUrl': videoController.text,
                // 'imageUrl': imageController.text,
              });
              Navigator.pop(context);
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  void _showEditModulDialog(BuildContext context, DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;
    final titleController = TextEditingController(text: data['title']);
    final priceController = TextEditingController(text: data['price'].toString());
    final idController = TextEditingController(text: data['id'].toString());
    final descController = TextEditingController(text: data['description']);
    String selectedLevel = data['level'] ?? "Beginner";
    // final durationController = TextEditingController(text: data['duration'] ?? '',);
    final videoController = TextEditingController(text: data['videoUrl'] ?? '',);
    // final imageController = TextEditingController(text: data['imageUrl'] ?? '',);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: darkPurple,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text("Edit Modul", style: const TextStyle(color: cream, fontSize: 20, fontWeight: FontWeight.bold)),   
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: idController,
                style: const TextStyle(
                  color: cream,
                  fontSize: 16,
                ),
                cursorColor: funkyPink,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration("ID Modul"),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                style: const TextStyle(
                  color: cream,
                  fontSize: 16,
                ),
                cursorColor: funkyPink,
                decoration: _inputDecoration("Judul Modul"),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: priceController,
                style: const TextStyle(
                  color: cream,
                  fontSize: 16,
                ),
                cursorColor: funkyPink,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration("Harga (Koin)"),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descController,
                style: const TextStyle(
                  color: cream,
                  fontSize: 16,
                ),
                cursorColor: funkyPink,
                decoration: _inputDecoration("Deskripsi Materi"),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                style: const TextStyle(
                  color: funkyPink,
                  fontSize: 16,
                ),
                value: selectedLevel,
                items: const [
                  DropdownMenuItem(value: "Beginner", child: Text("Beginner")),
                  DropdownMenuItem(value: "Intermediate", child: Text("Intermediate")),
                  DropdownMenuItem(value: "Advanced", child: Text("Advanced")),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedLevel = value!;
                  });
                },
                decoration: _inputDecoration("Level"),
              ),

              // const SizedBox(height: 16),
              // TextField(
              //   controller: durationController,
              //   style: const TextStyle(color: cream),
              //   cursorColor: funkyPink,
              //   decoration: _inputDecoration("Durasi (contoh: 15 menit)"),
              // ),

              const SizedBox(height: 16),
              TextField(
                controller: videoController,
                style: const TextStyle(color: cream),
                cursorColor: funkyPink,
                decoration: _inputDecoration("Link YouTube"),
              ),

              // const SizedBox(height: 16),
              // TextField(
              //   controller: imageController,
              //   style: const TextStyle(color: cream),
              //   cursorColor: funkyPink,
              //   decoration: _inputDecoration("Link Gambar"),
              // ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () async {
              await doc.reference.update({
                'id': int.parse(idController.text),
                'title': titleController.text,
                'description': descController.text,
                'price': int.parse(priceController.text),

                'level': selectedLevel,
                // 'duration': durationController.text,
                'videoUrl': videoController.text,
                // 'imageUrl': imageController.text,
              });
              Navigator.pop(context);
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  // Letakkan di sini
  void _confirmDelete(BuildContext context, DocumentSnapshot doc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: darkPurple,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text("Hapus Modul?", style: TextStyle(color: cream)),
        content: const Text("Data yang dihapus tidak bisa dikembalikan.", style: TextStyle(color: cream)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal", style: TextStyle(color: cream))),
          TextButton(
            onPressed: () async {
              await doc.reference.delete();
              Navigator.pop(context);
            }, 
            child: const Text("Hapus", style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );
  }

  // 1. Tambahkan fungsi ini di dalam _AdminDashboardScreenState
  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: darkPurple,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          "Logout Admin",
          style: TextStyle(color: cream),
        ),
        content: const Text(
          "Apakah yakin ingin keluar dari Knit Nest Admin?",
          style: TextStyle(color: softLilac),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Batal",
              style: TextStyle(color: softLilac),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                  (route) => false,
                );
              }
            },
            child: const Text(
              "Ya, Logout",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: darkBg,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Knit Nest Admin",
          style: GoogleFonts.dmSerifDisplay(
            color: cream,
            fontSize: 28,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: softPink),
            onPressed: () => _showLogoutConfirmation(context),
          )
        ],
      ),
      // FAB sekarang buat TAMBAH MODUL
      floatingActionButton: FloatingActionButton(
        backgroundColor: funkyPink,
        child: const Icon(Icons.add,color: Colors.white),
        onPressed: () => _showAddModulDialog(context),
      ),
      body: _buildModulManager(),
    );
  }

  // --- TAB 1: MANAJEMEN MODUL ---
  Widget _buildModulManager() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('modules').orderBy('id').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        var docs = snapshot.data!.docs;
        
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            var item = docs[index].data() as Map<String, dynamic>;
            return Container(
              margin: const EdgeInsets.only(bottom: 15),
              decoration: BoxDecoration(
                color: darkPurple,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: softLilac.withOpacity(.2),
                ),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: funkyPink,
                  child: Text(
                    "${item['id']}",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(
                  item['title'],
                  style: const TextStyle(
                    color: cream,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  "${item['price']} Koin",
                  style: const TextStyle(color: softLilac),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: softPink),
                      onPressed: () => _showEditModulDialog(context, docs[index]),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () => _confirmDelete(context, docs[index]),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}