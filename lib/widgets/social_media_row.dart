import 'package:flutter/material.dart';

class SocialMediaRow extends StatelessWidget {
  const SocialMediaRow({super.key});

  void _tampilkanSnackBar(BuildContext context, String nama) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Kamu menekan $nama'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.camera_alt),
          color: Colors.pink,
          tooltip: 'Instagram',
          onPressed: () => _tampilkanSnackBar(context, 'Instagram'),
        ),
        IconButton(
          icon: const Icon(Icons.work),
          color: Colors.blue,
          tooltip: 'LinkedIn',
          onPressed: () => _tampilkanSnackBar(context, 'LinkedIn'),
        ),
        IconButton(
          icon: const Icon(Icons.code),
          color: Colors.black87,
          tooltip: 'GitHub',
          onPressed: () => _tampilkanSnackBar(context, 'GitHub'),
        ),
      ],
    );
  }
}