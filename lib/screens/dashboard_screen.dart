import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  final List<Map<String, dynamic>> compras = [
    {'mes': 'Ene', 'total': 120},
    {'mes': 'Feb', 'total': 90},
    {'mes': 'Mar', 'total': 150},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dashboard Admin')),
      body: ListView(
        children: compras.map((e) => ListTile(
          title: Text('Mes: ${e['mes']}'),
          trailing: Text('Total: \$${e['total']}'),
        )).toList(),
      ),
    );
  }
}
