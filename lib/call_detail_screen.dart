import 'package:flutter/material.dart';

class CallDetailScreen extends StatelessWidget {
  const CallDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Call Details'),
      ),
      body: const Center(
        child: Text('Call Detail Screen'),
      ),
    );
  }
}
