import 'package:flutter/material.dart';

import 'profile_screen.dart';

class ProfileRouteScreen extends StatelessWidget {
  const ProfileRouteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: const ProfileScreen(),
    );
  }
}
