import 'package:flutter/material.dart';
import '../widgets/profile_photo.dart';
import '../widgets/profile_info.dart';
import '../widgets/social_media_row.dart';
import 'about_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Mahasiswa'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Tentang Aplikasi',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AboutScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Bagian foto: mengambil 2 bagian dari ruang yang tersedia
            const Expanded(
              flex: 2,
              child: Center(
                child: ProfilePhoto(radius: 60),
              ),
            ),
            // Bagian informasi: mengambil 3 bagian dari ruang yang tersedia
            const Expanded(
              flex: 3,
              child: SingleChildScrollView(
                child: ProfileInfo(
                  name: 'MOH. ALFIQRI A DG MASESE',
                  nim: '25.11.6548',
                  programStudi: 'S1 Informatika',
                  email: 'm.alfiqri@students.amikom.ac.id',
                  lokasi: 'Yogyakarta, Indonesia',
                ),
              ),
            ),
            const SocialMediaRow(),
            const SizedBox(height: 16),
            // Tombol aksi: masing-masing Flexible dengan flex 1
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Flexible(
                  flex: 1,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.share),
                    label: const Text('Bagikan'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}