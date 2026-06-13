import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_application_1_new/services/cart_service.dart';
import 'package:flutter_application_1_new/screens/navigation_wrapper.dart';


class MainAppScreen extends StatefulWidget {
  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> with WidgetsBindingObserver {
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initNotifications();
  }

  Future<void> _initNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _notifications.initialize(settings);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.paused) {
      final hasItems = await CartService.hasItemsInCart(); // tu lógica
      if (hasItems) {
        _showReminderNotification();
      }
    }
  }

  Future<void> _showReminderNotification() async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'cart_channel',
        'Carrito Abandonado',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );

    await _notifications.show(
      0,
      '¡No olvides tu pedido!',
      'No se te olvide finalizar tu pedido, porque con AndrewShop tus compras son seguras',
      details,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NavigationWrapper(), // tu navegación principal
    );
  }
}
