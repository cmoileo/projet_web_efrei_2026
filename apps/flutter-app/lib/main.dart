import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: LearnAtHomeApp()));
}

/// Point d'entrée de l'application Learn@Home.
class LearnAtHomeApp extends StatelessWidget {
  const LearnAtHomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Learn@Home',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      // TODO: remplacer par RouterConfig GoRouter une fois les routes définies
      home: const Scaffold(body: Center(child: Text('Learn@Home'))),
    );
  }
}
