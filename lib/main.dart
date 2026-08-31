import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Buku Kontak',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          primary: Colors.blue,
          surface: Colors.white,
        ),
      ),
      home: const ContactHomePage(),
    );
  }
}

/// Model Data Kontak
class Contact {
  String id;
  String name;
  String email;
  String phone;
  String category;
  bool isFavorite;

  Contact({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.category = 'Teman',
    this.isFavorite = false,
  });
}

/// Halaman Utama (Beranda) Buku Kontak
class ContactHomePage extends StatefulWidget {
  const ContactHomePage({super.key});

  @override
  State<ContactHomePage> createState() => _ContactHomePageState();
}

class _ContactHomePageState extends State<ContactHomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Daftar kontak awal
  List<Contact> contacts = [
    Contact(
      id: '1',
      name: 'Annisa Kusumastuti',
      email: 'nisak@gmail.com',
      phone: '0895421903057',
      category: 'Teman',
      isFavorite: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1E293B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _addContact(Contact newContact) {
    setState(() {
      contacts.insert(0, newContact);
    });
    _showToast('Kontak "${newContact.name}" berhasil disimpan!');
  }

  void _toggleFavorite(Contact contact) {
    setState(() {
      contact.isFavorite = !contact.isFavorite;
    });
    if (contact.isFavorite) {
      _showToast('${contact.name} ditambahkan ke Kontak Favorit');
    } else {
      _showToast('${contact.name} dihapus dari Kontak Favorit');
    }
  }

  void _deleteContact(Contact contact) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        title: const Text('Hapus Kontak?'),
        content: Text('Apakah kamu yakin ingin menghapus "${contact.name}" dari daftar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              setState(() {
                contacts.removeWhere((c) => c.id == contact.id);
              });
              Navigator.pop(context);
              _showToast('Kontak berhasil dihapus');
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _editContact(Contact contact) {
    final editNameController = TextEditingController(text: contact.name);
    final editEmailController =
        TextEditingController(text: contact.email == '-' ? '' : contact.email);
    final editPhoneController = TextEditingController(text: contact.phone);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          title: const Row(
            children: [
              Icon(Icons.edit_note_rounded, color: Colors.blue),
              SizedBox(width: 8),
              Text(
                'Edit Kontak',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 360,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: editNameController,
                    decoration: _inputDecoration('Nama Lengkap', Icons.person_outline),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: editPhoneController,
                    keyboardType: TextInputType.phone,
                    decoration: _inputDecoration('No Handphone', Icons.phone_outlined),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: editEmailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _inputDecoration('Email (Opsional)', Icons.mail_outline),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                if (editNameController.text.trim().isEmpty ||
                    editPhoneController.text.trim().isEmpty) {
                  _showToast('Nama dan Nomor HP tidak boleh kosong');
                  return;
                }
                setState(() {
                  contact.name = editNameController.text.trim();
                  contact.email = editEmailController.text.trim().isNotEmpty
                      ? editEmailController.text.trim()
                      : '-';
                  contact.phone = editPhoneController.text.trim();
                });
                Navigator.pop(context);
                _showToast('Kontak berhasil diperbarui!');
              },
              child: const Text('Simpan Perubahan'),
            ),
          ],
        );
      },
    );
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    _showToast('$label berhasil disalin: $text');
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
      prefixIcon: Icon(icon, size: 18, color: const Color(0xFF64748B)),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.blue, width: 1.5),
      ),
    );
  }

  void _navigateToAddContact() async {
    final newContact = await Navigator.push<Contact>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddContactPage(),
      ),
    );

    if (newContact != null) {
      _addContact(newContact);
    }
  }

  void _navigateToAbout() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AboutPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final favoriteContacts = contacts.where((c) => c.isFavorite).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('BUKU KONTAK'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(
              icon: Icon(Icons.contacts),
              text: 'Kontak',
            ),
            Tab(
              icon: Icon(Icons.star),
              text: 'Favorit',
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'BUKU KONTAK',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.contacts, color: Color(0xFF334155)),
              title: const Text('Kontak', style: TextStyle(fontWeight: FontWeight.w500)),
              onTap: () {
                Navigator.pop(context); // Tutup drawer
                _tabController.animateTo(0); // Pindah ke tab Kontak
              },
            ),
            ListTile(
              leading: const Icon(Icons.add, color: Color(0xFF334155)),
              title: const Text('Tambah Kontak', style: TextStyle(fontWeight: FontWeight.w500)),
              onTap: () {
                Navigator.pop(context); // Tutup drawer
                _navigateToAddContact(); // Navigasi ke Tambah Kontak
              },
            ),
            ListTile(
              leading: const Icon(Icons.star, color: Color(0xFF334155)),
              title: const Text('Favorit', style: TextStyle(fontWeight: FontWeight.w500)),
              onTap: () {
                Navigator.pop(context); // Tutup drawer
                _tabController.animateTo(1); // Pindah ke tab Favorit
              },
            ),
            ListTile(
              leading: const Icon(Icons.info, color: Color(0xFF334155)),
              title: const Text('Tentang', style: TextStyle(fontWeight: FontWeight.w500)),
              onTap: () {
                Navigator.pop(context); // Tutup drawer
                _navigateToAbout(); // Navigasi ke Halaman Tentang
              },
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. Tab Kontak
          _buildContactList(contacts, isFavoriteTab: false),

          // 2. Tab Favorit
          _buildContactList(favoriteContacts, isFavoriteTab: true),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        onPressed: _navigateToAddContact,
        tooltip: 'Tambah Kontak',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildContactList(List<Contact> list, {required bool isFavoriteTab}) {
    if (list.isEmpty) {
      return Center(
        child: Text(
          isFavoriteTab ? 'Belum ada kontak favorit.' : 'Belum ada kontak',
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF64748B),
          ),
        ),
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final contact = list[index];
            return _buildContactCard(contact);
          },
        ),
      ),
    );
  }

  Widget _buildContactCard(Contact contact) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon Profil
            const CircleAvatar(
              radius: 20,
              backgroundColor: Color(0xFFE2E8F0),
              child: Icon(Icons.person, color: Color(0xFF64748B), size: 24),
            ),
            const SizedBox(width: 14),

            // Detail Kontak
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contact.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 3),
                  if (contact.email.isNotEmpty && contact.email != '-')
                    Row(
                      children: [
                        const Icon(Icons.mail_outline, size: 13, color: Color(0xFF64748B)),
                        const SizedBox(width: 4),
                        Text(
                          contact.email,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.phone_outlined, size: 13, color: Color(0xFF64748B)),
                      const SizedBox(width: 4),
                      Text(
                        contact.phone,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF334155),
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => _copyToClipboard(contact.phone, 'Nomor HP'),
                        child: const Text(
                          'Salin',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Aksi
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    contact.isFavorite ? Icons.star : Icons.star_border,
                    color: contact.isFavorite ? Colors.amber : const Color(0xFF94A3B8),
                    size: 22,
                  ),
                  tooltip: contact.isFavorite ? 'Hapus Favorit' : 'Jadikan Favorit',
                  onPressed: () => _toggleFavorite(contact),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF64748B)),
                  tooltip: 'Edit',
                  onPressed: () => _editContact(contact),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFDC2626)),
                  tooltip: 'Hapus',
                  onPressed: () => _deleteContact(contact),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Halaman Tambah Kontak Baru
class AddContactPage extends StatefulWidget {
  const AddContactPage({super.key});

  @override
  State<AddContactPage> createState() => _AddContactPageState();
}

class _AddContactPageState extends State<AddContactPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  void _saveContact() {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama lengkap harus diisi!'),
          backgroundColor: Color(0xFF1E293B),
        ),
      );
      return;
    }

    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nomor handphone harus diisi!'),
          backgroundColor: Color(0xFF1E293B),
        ),
      );
      return;
    }

    final newContact = Contact(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: email.isNotEmpty ? email : '-',
      phone: phone,
      category: 'Teman',
      isFavorite: false,
    );

    Navigator.pop(context, newContact);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Kontak'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.all(20.0),
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap',
                  border: UnderlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: UnderlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'No Handphone',
                  border: UnderlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: SizedBox(
                  width: 120,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE2E8F0),
                      foregroundColor: const Color(0xFF334155),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: _saveContact,
                    child: const Text(
                      'Simpan',
                      style: TextStyle(fontWeight: FontWeight.w500),
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
}

/// Halaman Tentang (Profil Siswa)
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tentang'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 30),
                // Foto / Avatar Profil
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.blue.shade100, width: 3),
                  ),
                  child: const CircleAvatar(
                    radius: 50,
                    backgroundColor: Color(0xFFE2E8F0),
                    child: Icon(
                      Icons.person,
                      size: 60,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Albanie Setyawan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'XII RPL B',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'SMK Negeri 5 Surakarta',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
