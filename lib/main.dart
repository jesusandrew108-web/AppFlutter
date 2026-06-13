// main.dart
import 'package:flutter/material.dart';
import 'services/notification_service.dart';
import 'login_form.dart';
import 'screens/navigation_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AndrewShop',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: Colors.black,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginForm(),
        '/home': (context) => NavigationWrapper(),
      },
    );
  }
}
