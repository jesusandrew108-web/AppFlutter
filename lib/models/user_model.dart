class UserModel {
  final int id;
  final String email;
  final String nombre;
  final String apP;
  final String apM;
  final String role;

  UserModel({
    required this.id,
    required this.email,
    required this.nombre,
    required this.apP,
    required this.apM,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      nombre: json['nombre'] ?? '',
      apP: json['apP'] ?? '',
      apM: json['apM'] ?? '',
      role: json['role'] ?? 'cliente',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'nombre': nombre,
    'apP': apP,
    'apM': apM,
    'role': role,
  };
}
