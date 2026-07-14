// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class AdminModulScreen extends StatefulWidget {
//   const AdminModulScreen({super.key});

//   @override
//   State<AdminModulScreen> createState() => _AdminModulScreenState();
// }

// class _AdminModulScreenState extends State<AdminModulScreen> {
//   final _formKey = GlobalKey<FormState>();
  
//   // Controller buat ambil teks dari inputan
//   final _idController = TextEditingController();
//   final _titleController = TextEditingController();
//   final _descController = TextEditingController();
//   final _priceController = TextEditingController();
//   final _videoController = TextEditingController();

//   bool _isLoading = false;

//   void _simpanModul() async {
//     if (_formKey.currentState!.validate()) {
//       setState(() => _isLoading = true);
      
//       try {
//         await FirebaseFirestore.instance.collection('modules').add({
//           'id': int.parse(_idController.text),
//           'title': _titleController.text,
//           'desc': _descController.text,
//           'price': int.parse(_priceController.text),
//           'videoUrl': _videoController.text,
//           'createdAt': FieldValue.serverTimestamp(), // Biar tahu kapan dibuat
//         });

//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text("Berhasil! Modul baru sudah terajut 🧶")),
//           );
//           _formKey.currentState!.reset(); // Kosongkan form lagi
//         }
//       } catch (e) {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text("Waduh, error: $e")),
//           );
//         }
//       } finally {
//         setState(() => _isLoading = false);
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("KnitNest Admin 🛠️"),
//         backgroundColor: const Color(0xFF8E9775),
//       ),
//       body: _isLoading 
//         ? const Center(child: CircularProgressIndicator()) 
//         : SingleChildScrollView(
//             padding: const EdgeInsets.all(20.0),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 children: [
//                   _buildInput(_idController, "ID Modul (Angka untuk urutan)", Icons.numbers, isNumber: true),
//                   _buildInput(_titleController, "Judul Modul", Icons.title),
//                   _buildInput(_descController, "Deskripsi Singkat", Icons.description),
//                   _buildInput(_priceController, "Harga Koin (Isi 0 jika gratis)", Icons.monetization_on, isNumber: true),
//                   _buildInput(_videoController, "Link Video YouTube", Icons.play_circle_fill),
                  
//                   const SizedBox(height: 30),
                  
//                   SizedBox(
//                     width: double.infinity,
//                     height: 50,
//                     child: ElevatedButton(
//                       onPressed: _simpanModul,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFF5A6344),
//                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
//                       ),
//                       child: const Text("Tambahkan Modul", style: TextStyle(color: Colors.white, fontSize: 16)),
//                     ),
//                   )
//                 ],
//               ),
//             ),
//           ),
//     );
//   }

//   Widget _buildInput(TextEditingController controller, String label, IconData icon, {bool isNumber = false}) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 15),
//       child: TextFormField(
//         controller: controller,
//         keyboardType: isNumber ? TextInputType.number : TextInputType.text,
//         decoration: InputDecoration(
//           labelText: label,
//           prefixIcon: Icon(icon, color: const Color(0xFF8E9775)),
//           border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//         ),
//         validator: (value) => value == null || value.isEmpty ? "Jangan kosong ya!" : null,
//       ),
//     );
//   }
// }