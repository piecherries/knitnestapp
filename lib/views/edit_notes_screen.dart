import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const darkBg = Color(0xFF140F1F);
const darkCard = Color(0xFF1E1830);
const softPink = Color(0xFFFFB7D5);
const funkyPink = Color(0xFFFF8FAB);
const softLilac = Color(0xFFD8C4FF);
const gold = Color(0xFFFFB703);

class EditNoteScreen extends StatefulWidget {
  final String? noteId;
  final Map<String, dynamic>? initialData;
  final CollectionReference notesRef;

  const EditNoteScreen({super.key, this.noteId, this.initialData, required this.notesRef});

  @override
  State<EditNoteScreen> createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  final titleController = TextEditingController();
  final descController = TextEditingController();
  final yarnController = TextEditingController();
  final hookController = TextEditingController();
  List<String> _tempYarns = [];
  List<String> _tempHooks = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      titleController.text = widget.initialData!['title'] ?? "";
      descController.text = widget.initialData!['desc'] ?? "";
      _tempYarns = List<String>.from(widget.initialData!['yarns'] ?? []);
      _tempHooks = List<String>.from(widget.initialData!['hooks'] ?? []);
    }
  }

  // --- HELPER UNTUK STYLE INPUT (RAHASIA KONSISTENSI) ---
  InputDecoration _knitInputDecoration(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      prefixIcon: icon != null ? Icon(icon, color: funkyPink, size: 22) : null,
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: funkyPink, width: 2),
      ),
      floatingLabelStyle: TextStyle(color: funkyPink),
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.noteId == null
              ? "New Crochet Note"
              : "Edit Crochet Note",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          if (widget.noteId != null)
            IconButton(
              icon: const Icon(
                Icons.delete_rounded,
                color: Colors.redAccent,
              ),
              onPressed: () => _confirmDelete(context),
            ),

          IconButton(
            icon: const Icon(
              Icons.check_circle_rounded,
              color: Color(0xFFFFB7D5),
            ),
            onPressed: _saveData,
          ),
        ],
      ),
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
        child: SafeArea(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(), // Tutup keyboard pas klik area kosong
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. JUDUL PROYEK (Input Utama)
                  TextField(
                    controller: titleController,
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white,),
                    decoration: InputDecoration(
                      hintText: "Nama Proyek",
                      hintStyle: const TextStyle(color: Colors.white38),
                      border: InputBorder.none,
                    ),
                  ),
                  Divider(color: softLilac.withOpacity(.25),),
                  
                  const SizedBox(height: 10),

                  // 2. INPUT SEKSI: BENANG
                  _buildInputSection(
                    icon: Icons.line_weight, 
                    label: "Jenis Benang",
                    ctrl: yarnController,
                    items: _tempYarns,
                  ),
                  const SizedBox(height: 25),

                  // 3. INPUT SEKSI: HAKPEN
                  _buildInputSection(
                    icon: Icons.architecture, 
                    label: "Ukuran Hakpen",
                    ctrl: hookController,
                    items: _tempHooks,
                  ),
                  const SizedBox(height: 40),

                  // 4. CATATAN POLA (Warna Sage Tua)
                  Text("CATATAN POLA", 
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.5)),
                  const SizedBox(height: 15),
                  TextField(
                    controller: descController,
                    maxLines: null,
                    style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    height: 1.5,
                    ),
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      hintText: "Tulis polanya di sini...",
                      hintStyle: const TextStyle(color: Colors.white70,),
                      filled: true,
                      fillColor: Colors.white.withOpacity(.08),
                      contentPadding: const EdgeInsets.all(20),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15), 
                        borderSide: BorderSide(color: Colors.grey.shade200)
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15), 
                        borderSide: BorderSide(color: funkyPink, width: 2)
                      ),
                    ),
                  ),
                  // Tambahkan jarak bawah ekstra agar tidak terhalang keyboard saat scroll
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // WIDGET HELPER BIAR SEMUA INPUT SEKSI SAMA
  Widget _buildInputSection({required IconData icon, required String label, required TextEditingController ctrl, required List<String> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: ctrl, style: const TextStyle(color: Colors.white, fontSize: 16,),
          decoration: _knitInputDecoration(label, icon: icon).copyWith(
            suffixIcon: IconButton(
              icon: Icon(Icons.add_circle, color: funkyPink),
              onPressed: () {
                if (ctrl.text.isNotEmpty) {
                  setState(() => items.add(ctrl.text.trim()));
                  ctrl.clear();
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map((item) => Chip(
            label: Text( item, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
            backgroundColor: const Color(0xFF3A2958),
            deleteIcon: const Icon(Icons.cancel, size: 16, color: Color(0xFFFFB7D5),),

            onDeleted: () => setState(() => items.remove(item)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            side: BorderSide(color: const Color(0xFFD8C4FF).withOpacity(.35),),
          )).toList(),
        ),
      ],
    );
  }

  // --- LOGIKA FIREBASE (TETAP SAMA) ---
  void _saveData() async {
    if (titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Isi dulu judulnya ya, Put!")),
      );
      return;
    }
    
    Map<String, dynamic> data = {
      'title': titleController.text.trim(),
      'yarns': _tempYarns,
      'hooks': _tempHooks,
      'desc': descController.text.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    try {
      if (widget.noteId == null) {
        data['createdAt'] = FieldValue.serverTimestamp();
        await widget.notesRef.add(data);
      } else {
        await widget.notesRef.doc(widget.noteId).update(data);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal: $e")));
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Hapus Proyek?"),
        content: const Text("Yakin mau hapus catatan ini?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          TextButton(
            onPressed: () async {
              await widget.notesRef.doc(widget.noteId).delete();
              if (mounted) {
                Navigator.pop(context);
                Navigator.pop(context);
              }
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}