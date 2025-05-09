import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'TASKMANAGER/service/TaskNotificationService.dart';
import 'TASKMANAGER/LoginScreen.dart';
import 'TASKMANAGER/RegisterScreen.dart';
import 'TASKMANAGER/HomeScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Init Firebase và Notification
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await TaskNotificationService.init();

  runApp(const TaskManagerApp());
}

class TaskManagerApp extends StatelessWidget {
  const TaskManagerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '🗂️ Task Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.grey.shade50,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/home': (_) => const HomeScreen(),
      },
    );
  }
}
