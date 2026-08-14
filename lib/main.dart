import 'package:flutter/material.dart';

const apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:8081',
);

void main() {
  runApp(const EquipmentManagerApp());
}

class EquipmentManagerApp extends StatelessWidget {
  const EquipmentManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Equipment Manager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const EquipmentOverviewPage(),
    );
  }
}

class EquipmentOverviewPage extends StatelessWidget {
  const EquipmentOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Equipment Manager')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Frontend bereit',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Der Flutter-Web-Container ist gestartet. Die API-Anbindung folgt in einem separaten Issue.',
                    ),
                    const SizedBox(height: 16),
                    Text('API-Basis-URL: $apiBaseUrl'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
