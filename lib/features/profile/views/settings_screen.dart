import 'package:flutter/material.dart';

import 'profile_screen.dart';

/// Legacy standalone SettingsScreen wrapper pointing to unified ProfileScreen with initialTab: 1
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProfileScreen(initialTab: 1);
  }
}
