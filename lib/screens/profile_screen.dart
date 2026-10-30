import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/user_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _favController = TextEditingController(); // Latihan 3
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  bool _controllersInitialized = false;

  // Latihan 5: karakter yang dianggap berbahaya pada nama
  static final RegExp _dangerousChars = RegExp(r'[<>{}$`\\]');

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controllersInitialized) return;

    final provider = UserProvider.of(context);
    _nameController = TextEditingController(text: provider.user.name);
    _emailController = TextEditingController(text: provider.user.email);
    _controllersInitialized = true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _favController.dispose();
    super.dispose();
  }

  void _notify(ScaffoldMessengerState messenger, String text,
      {bool error = false}) {
    messenger.showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: error ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    // Ambil objek yang dibutuhkan sebelum proses asinkron
    final provider = UserProvider.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();

    // Latihan 5b: tolak nama yang mengandung karakter berbahaya
    if (_dangerousChars.hasMatch(name)) {
      _notify(messenger, 'Nama mengandung karakter yang tidak diizinkan',
          error: true);
      return;
    }

    // Latihan 5a: simulasi cek email yang sudah digunakan
    final prefs = await SharedPreferences.getInstance();
    final owner = (prefs.getString('user_email') ?? '').toLowerCase();
    final registered = prefs.getStringList('registered_emails') ?? <String>[];
    final emailKey = email.toLowerCase();

    if (registered.contains(emailKey) && emailKey != owner) {
      _notify(messenger, 'Email sudah digunakan oleh akun lain', error: true);
      return;
    }

    final updatedUser = provider.user.copyWith(
      name: name,
      email: email,
      isLoggedIn: true,
    );
    await provider.updateUser(updatedUser);

    if (!registered.contains(emailKey)) {
      registered.add(emailKey);
      await prefs.setStringList('registered_emails', registered);
    }

    _notify(messenger, 'Profil berhasil disimpan');
  }

  // Latihan 3: tambah favorit
  void _addFavorite() {
    final provider = UserProvider.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final item = _favController.text.trim();

    if (item.isEmpty) {
      _notify(messenger, 'Favorit tidak boleh kosong', error: true);
      return;
    }
    final exists =
        provider.favorites.any((f) => f.toLowerCase() == item.toLowerCase());
    if (exists) {
      _notify(messenger, '"$item" sudah ada di daftar favorit', error: true);
      return;
    }

    provider.addFavorite(item);
    _favController.clear();
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Apakah Anda yakin ingin logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              UserProvider.of(context).logout();
              Navigator.pop(context);
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = UserProvider.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          if (provider.user.isLoggedIn)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _logout,
              tooltip: 'Logout',
            ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 16),
                          const CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.deepPurple,
                            child: Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Nama',
                              prefixIcon: Icon(Icons.person),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Nama tidak boleh kosong';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email),
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Email tidak boleh kosong';
                              }
                              final emailRegex =
                                  RegExp(r'^[^@]+@[^@]+\.[^@]+');
                              if (!emailRegex.hasMatch(value.trim())) {
                                return 'Format email tidak valid';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _saveProfile,
                            icon: const Icon(Icons.save),
                            label: const Text('Simpan Profil'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Latihan 3: daftar favorit
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Daftar Favorit (Hobi)',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _favController,
                                    decoration: const InputDecoration(
                                      hintText: 'Tambah hobi baru',
                                      border: OutlineInputBorder(),
                                      isDense: true,
                                    ),
                                    onSubmitted: (_) => _addFavorite(),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton.filled(
                                  onPressed: _addFavorite,
                                  icon: const Icon(Icons.add),
                                  tooltip: 'Tambah favorit',
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (provider.favorites.isEmpty)
                              const Text(
                                'Belum ada favorit.',
                                style: TextStyle(fontSize: 12),
                              )
                            else
                              ...provider.favorites.map(
                                (item) => ListTile(
                                  dense: true,
                                  contentPadding: EdgeInsets.zero,
                                  leading: const Icon(
                                    Icons.favorite,
                                    color: Colors.pink,
                                  ),
                                  title: Text(item),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete_outline),
                                    tooltip: 'Hapus',
                                    onPressed: () =>
                                        provider.removeFavorite(item),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      color: Colors.amber[50],
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.info, color: Colors.amber[800]),
                                const SizedBox(width: 8),
                                const Text(
                                  'Catatan Keamanan',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Data disimpan di SharedPreferences (plaintext). '
                              'Jangan simpan password atau data sensitif di sini. '
                              'Gunakan secure storage untuk data sensitif.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black87,
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
    );
  }
}