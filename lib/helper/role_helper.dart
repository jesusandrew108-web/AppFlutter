// role_helper.dart
class RoleHelper {
  static bool isAdmin(String role) => role == 'administrador';
  static bool isClient(String role) => role == 'cliente';
  static bool isGuest(String role) => role == 'guest';
}
