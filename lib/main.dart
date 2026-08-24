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
      title: 'Buku Kontak Siswa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F172A),
          primary: const Color(0xFF0F172A),
          surface: Colors.white,
        ),
      ),
      home: const ContactFormPage(),
    );
  }
}

class Contact {
  String id;
  String name;
  String email;
  String phone;
  String category;

  Contact({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.category = 'Teman Sekelas',
  });
}

class ContactFormPage extends StatefulWidget {
  const ContactFormPage({super.key});

  @override
  State<ContactFormPage> createState() => _ContactFormPageState();
}

class _ContactFormPageState extends State<ContactFormPage> {

  List<Contact> contacts = [
  ];

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  String searchQuery = '';

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    categoryController.dispose();
    searchController.dispose();
    super.dispose();
  }

  void addContact() {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final category = categoryController.text.trim();

    if (name.isEmpty) {
      _showToast('Nama lengkap harus diisi!');
      return;
    }
    if (phone.isEmpty) {
      _showToast('Nomor HP harus diisi!');
      return;
    }

    setState(() {
      contacts.insert(
        0,
        Contact(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: name,
          email: email.isNotEmpty ? email : '-',
          phone: phone,
          category: category.isNotEmpty ? category : 'Teman',
        ),
      );
    });

    nameController.clear();
    emailController.clear();
    phoneController.clear();
    categoryController.clear();
    _showToast('Kontak "$name" berhasil disimpan!');
  }

  void editContact(Contact contact) {
    final editNameController = TextEditingController(text: contact.name);
    final editEmailController = TextEditingController(text: contact.email == '-' ? '' : contact.email);
    final editPhoneController = TextEditingController(text: contact.phone);
    final editCategoryController = TextEditingController(text: contact.category);

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
              Icon(Icons.edit_note_rounded, color: Color(0xFF0F172A)),
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
                    decoration: _inputDecoration('Nomor HP / WhatsApp', Icons.phone_outlined),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: editEmailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _inputDecoration('Email (Opsional)', Icons.mail_outline),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: editCategoryController,
                    decoration: _inputDecoration('Kategori / Jabatan (cth: Teman, Guru, dll)', Icons.badge_outlined),
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
                backgroundColor: const Color(0xFF0F172A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                if (editNameController.text.trim().isEmpty || editPhoneController.text.trim().isEmpty) {
                  _showToast('Nama dan Nomor HP tidak boleh kosong');
                  return;
                }
                setState(() {
                  contact.name = editNameController.text.trim();
                  contact.email = editEmailController.text.trim().isNotEmpty ? editEmailController.text.trim() : '-';
                  contact.phone = editPhoneController.text.trim();
                  contact.category = editCategoryController.text.trim().isNotEmpty ? editCategoryController.text.trim() : 'Teman';
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

  void deleteContact(Contact contact) {
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

  void _showToast(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0F172A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    _showToast('$label berhasil disalin: $text');
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF475569), fontSize: 13),
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
        borderSide: const BorderSide(color: Color(0xFF0F172A), width: 1.5),
      ),
    );
  }

  List<Contact> get filteredContacts {
    if (searchQuery.isEmpty) return contacts;
    return contacts.where((c) {
      final q = searchQuery.toLowerCase();
      return c.name.toLowerCase().contains(q) ||
          c.phone.toLowerCase().contains(q) ||
          c.email.toLowerCase().contains(q) ||
          c.category.toLowerCase().contains(q);
    }).toList();
  }

  Color _getCategoryColor(String category) {
    if (category.isEmpty) return const Color(0xFF475569);
    final hash = category.toLowerCase().codeUnits.fold<int>(0, (p, e) => p + e);
    final colors = [
      const Color(0xFF2563EB), 
      const Color(0xFF7C3AED), 
      const Color(0xFF059669), 
      const Color(0xFFD97706), 
      const Color(0xFFDB2777), 
      const Color(0xFF0284C7), 
      const Color(0xFF4F46E5), 
      const Color(0xFF475569), 
    ];
    return colors[hash % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final list = filteredContacts;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.contacts_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Buku Kontak',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x05000000),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.person_add_alt_1_rounded, size: 18, color: Color(0xFF0F172A)),
                        SizedBox(width: 8),
                        Text(
                          'Tambah Kontak Baru',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: nameController,
                      decoration: _inputDecoration('Nama Lengkap *', Icons.person_outline),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: _inputDecoration('No Handphone*', Icons.phone_outlined),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _inputDecoration('Email (Opsional)', Icons.mail_outline),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: categoryController,
                      decoration: _inputDecoration('Kategori / Jabatan (cth: Teman, Guru,)', Icons.badge_outlined),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0F172A),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                            onPressed: addContact,
                            icon: const Icon(Icons.save_rounded, size: 18),
                            label: const Text(
                              'Simpan Kontak',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF475569),
                            side: const BorderSide(color: Color(0xFFCBD5E1)),
                            padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            nameController.clear();
                            emailController.clear();
                            phoneController.clear();
                            categoryController.clear();
                          },
                          child: const Text('Batal'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      onChanged: (val) => setState(() => searchQuery = val),
                      decoration: InputDecoration(
                        hintText: 'Cari nama, no HP, atau email...',
                        hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                        prefixIcon: const Icon(Icons.search_rounded, size: 18, color: Color(0xFF64748B)),
                        suffixIcon: searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close, size: 16),
                                onPressed: () {
                                  searchController.clear();
                                  setState(() => searchQuery = '');
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: Colors.white,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Text(
                      '${list.length} Kontak',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              if (list.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Center(
                    child: Column(
                      children: [
                        Icon(Icons.person_search_rounded, size: 40, color: Color(0xFF94A3B8)),
                        SizedBox(height: 10),
                        Text(
                          'Tidak ada kontak ditemukan',
                          style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...list.map((contact) {
                  final initial = contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '?';
                  final catColor = _getCategoryColor(contact.category);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x03000000),
                          blurRadius: 4,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Inisial Avatar
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: const Color(0xFF0F172A),
                            child: Text(
                              initial,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Info Kontak
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        contact.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: catColor.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        contact.category,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: catColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.phone_rounded, size: 13, color: Color(0xFF64748B)),
                                    const SizedBox(width: 4),
                                    Text(
                                      contact.phone,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
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
                                          color: Color(0xFF2563EB),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (contact.email != '-') ...[
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      const Icon(Icons.mail_outline_rounded, size: 13, color: Color(0xFF64748B)),
                                      const SizedBox(width: 4),
                                      Text(
                                        contact.email,
                                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),

                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF475569)),
                                tooltip: 'Edit',
                                onPressed: () => editContact(contact),
                                splashRadius: 18,
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFDC2626)),
                                tooltip: 'Hapus',
                                onPressed: () => deleteContact(contact),
                                splashRadius: 18,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}
