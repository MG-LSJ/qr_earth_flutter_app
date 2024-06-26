import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_earth/utils/constants.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Earth'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.goNamed('scanner'),
        label: const Text("Scan QR"),
        icon: const Icon(Icons.qr_code_scanner_rounded),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 30.0, 20.0, 0.0),
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Icon(
                          Icons.account_circle,
                          size: 50.0,
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      const Text(
                        'USERNAME',
                        style: TextStyle(
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      Text(
                        USER.username,
                        style: const TextStyle(
                          color: Colors.lightGreen,
                          letterSpacing: 2.0,
                          fontSize: 28.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 30.0),
                      const Text(
                        'POINTS',
                        style: TextStyle(
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      Text(
                        USER.codes_count.toString(),
                        style: const TextStyle(
                          color: Colors.lightGreen,
                          letterSpacing: 2.0,
                          fontSize: 28.0,
                          fontWeight: FontWeight.bold,
                        ),
                      )
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
