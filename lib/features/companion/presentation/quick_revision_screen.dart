import 'package:flutter/material.dart';

class QuickRevisionScreen extends StatelessWidget {
  const QuickRevisionScreen({super.key, required this.minutes});

  final int minutes;

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: SizedBox.shrink());
  }
}
