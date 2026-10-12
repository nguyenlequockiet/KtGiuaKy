import 'package:flutter/material.dart';
import 'screens/exam_list_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ToeicReadingApp());
}

class ToeicReadingApp extends StatelessWidget {
  const ToeicReadingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TOEIC Reading Prep Mobile App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const ExamListScreen(),
    );
  }
}
