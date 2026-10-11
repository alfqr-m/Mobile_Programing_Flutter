import 'package:flutter/material.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_info.dart';
import '../widgets/social_media_row.dart';
import '../widgets/action_buttons.dart';
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
            // Header: foto + nama + NIM
            const Expanded(
              flex: 3,
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: ProfileHeader(
                    name: 'MOH. ALFIQRI A DG MASESE',
                    nim: '25.11.6548',
                  ),
                ),
              ),
            ),
            // Detail: program studi, email, lokasi
            const Expanded(
              flex: 2,
              child: SingleChildScrollView(
                child: ProfileInfo(
                  programStudi: 'S1 Informatika',
                  email: 'm.alfiqri@students.amikom.ac.id',
                  lokasi: 'Yogyakarta, Indonesia',
                ),
              ),
            ),
            const SocialMediaRow(),
            const SizedBox(height: 16),
            const ActionButtons(),
          ],
        ),
      ),
    );
  }
}