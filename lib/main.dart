import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// === MODEL DATA ===
// Menambahkan field email sesuai Tugas Mandiri 3
class Catatan {
  String judul;
  String isi;
  String kategori;
  String email;
  final DateTime dibuatPada;

  Catatan({
    required this.judul,
    required this.isi,
    required this.kategori,
    required this.email,
    required this.dibuatPada,
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catatan Mahasiswa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
      },
      // Menggunakan onGenerateRoute untuk mengirim argumen ke halaman
      onGenerateRoute: (settings) {
        if (settings.name == '/tambah-edit') {
          final catatan = settings.arguments as Catatan?;
          return MaterialPageRoute(
            builder: (_) => TambahCatatanPage(catatanLama: catatan),
          );
        } else if (settings.name == '/detail') {
          final catatan = settings.arguments as Catatan;
          return MaterialPageRoute(
            builder: (_) => DetailCatatanPage(catatan: catatan),
          );
        }
        return null;
      },
    );
  }
}

// === HALAMAN UTAMA (HOME) ===
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // State untuk filter kategori
  String _filterKategori = 'Semua';
  final List<String> _opsiFilter = ['Semua', 'Kuliah', 'Tugas', 'Pribadi', 'Lainnya'];

  final List<Catatan> _catatan = [
    Catatan(
      judul: 'Belajar Flutter',
      isi: 'Mempelajari Stateful Widget, Form, dan Navigation.',
      kategori: 'Kuliah',
      email: 'mhs@univ.ac.id',
      dibuatPada: DateTime.now(),
    ),
  ];

  // Logic untuk memfilter list berdasarkan pilihan dropdown
  List<Catatan> get _catatanTerfilter {
    if (_filterKategori == 'Semua') return _catatan;
    return _catatan.where((c) => c.kategori == _filterKategori).toList();
  }

  Future<void> _navigasiForm([Catatan? catatan]) async {
    final hasil = await Navigator.pushNamed(
        context,
        '/tambah-edit',
        arguments: catatan
    );

    if (hasil is Catatan) {
      // Menggunakan setState untuk memperbarui UI
      setState(() {
        if (catatan != null) {
          int index = _catatan.indexOf(catatan);
          _catatan[index] = hasil;
        } else {
          _catatan.add(hasil);
        }
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Catatan berhasil ${catatan == null ? "ditambah" : "diperbarui"}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Mahasiswa'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Tugas Mandiri 2: Dropdown Filter di AppBar
        actions: [
          DropdownButton<String>(
            value: _filterKategori,
            icon: const Icon(Icons.filter_list, color: Colors.indigo),
            underline: const SizedBox(),
            onChanged: (String? newValue) {
              setState(() {
                _filterKategori = newValue!;
              });
            },
            items: _opsiFilter.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: _catatanTerfilter.isEmpty
          ? const Center(child: Text('Tidak ada catatan untuk kategori ini.'))
          : ListView.builder(
        itemCount: _catatanTerfilter.length,
        itemBuilder: (context, i) {
          final c = _catatanTerfilter[i];
          return ListTile(
            title: Text(c.judul),
            subtitle: Text('${c.kategori} • ${c.email}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _navigasiForm(c),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setState(() => _catatan.remove(c));
                  },
                ),
              ],
            ),
            onTap: () => Navigator.pushNamed(context, '/detail', arguments: c),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigasiForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

// === HALAMAN FORM (TAMBAH & EDIT) ===
class TambahCatatanPage extends StatefulWidget {
  final Catatan? catatanLama;
  const TambahCatatanPage({super.key, this.catatanLama});

  @override
  State<TambahCatatanPage> createState() => _TambahCatatanPageState();
}

class _TambahCatatanPageState extends State<TambahCatatanPage> {
  // GlobalKey untuk validasi form
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _judulCtrl;
  late TextEditingController _isiCtrl;
  late TextEditingController _emailCtrl;
  late String _kategori;
  final _kategoriOpsi = const ['Kuliah', 'Tugas', 'Pribadi', 'Lainnya'];

  @override
  void initState() {
    super.initState();
    // Mengisi field dengan data lama jika mode EDIT (Tugas Mandiri 1)
    _judulCtrl = TextEditingController(text: widget.catatanLama?.judul ?? '');
    _isiCtrl = TextEditingController(text: widget.catatanLama?.isi ?? '');
    _emailCtrl = TextEditingController(text: widget.catatanLama?.email ?? '');
    _kategori = widget.catatanLama?.kategori ?? 'Kuliah';
  }

  @override
  void dispose() {
    // Membebaskan resource controller
    _judulCtrl.dispose();
    _isiCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  void _simpan() {
    // Menjalankan validasi form sebelum simpan
    if (!_formKey.currentState!.validate()) return;

    final catatanBaru = Catatan(
      judul: _judulCtrl.text.trim(),
      isi: _isiCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      kategori: _kategori,
      dibuatPada: widget.catatanLama?.dibuatPada ?? DateTime.now(),
    );

    Navigator.pop(context, catatanBaru);
  }

  @override
  Widget build(BuildContext context) {
    bool isEdit = widget.catatanLama != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Catatan' : 'Tambah Catatan')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _judulCtrl,
              decoration: const InputDecoration(labelText: 'Judul', border: OutlineInputBorder()),
              validator: (v) => (v == null || v.isEmpty) ? 'Judul wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            // Tugas Mandiri 3: Field Email dengan Validasi Regex
            TextFormField(
              controller: _emailCtrl,
              decoration: const InputDecoration(
                labelText: 'Email Pengirim',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Email wajib diisi';
                // Pattern Regex untuk validasi email
                final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                if (!emailRegex.hasMatch(v)) return 'Format email tidak valid';
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _kategori,
              decoration: const InputDecoration(labelText: 'Kategori', border: OutlineInputBorder()),
              items: _kategoriOpsi.map((k) => DropdownMenuItem(value: k, child: Text(k))).toList(),
              onChanged: (v) => setState(() => _kategori = v!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _isiCtrl,
              maxLines: 5,
              decoration: const InputDecoration(labelText: 'Isi Catatan', border: OutlineInputBorder()),
              validator: (v) => (v == null || v.isEmpty) ? 'Isi wajib diisi' : null,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _simpan,
              icon: const Icon(Icons.save),
              label: Text(isEdit ? 'Simpan Perubahan' : 'Simpan Catatan'),
            ),
          ],
        ),
      ),
    );
  }
}

// === HALAMAN DETAIL ===
class DetailCatatanPage extends StatelessWidget {
  final Catatan catatan;
  const DetailCatatanPage({super.key, required this.catatan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Catatan')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(catatan.judul, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Chip(label: Text(catatan.kategori), backgroundColor: Colors.indigo.shade50),
                const SizedBox(width: 10),
                Text(catatan.email, style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const Divider(height: 32),
            Text(catatan.isi, style: const TextStyle(fontSize: 16, height: 1.5)),
          ],
        ),
      ),
    );
  }
}