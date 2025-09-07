import 'package:flutter/material.dart';

class AddMemberScreen extends StatelessWidget {
  const AddMemberScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Member'),
        backgroundColor: Colors.white,
      ),
      body: const Center(child: Text('Add Member Screen is here')),
    );
  }
}
