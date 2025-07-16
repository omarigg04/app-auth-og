import 'package:flutter/material.dart';
// import '../models/user.dart';
// import '../services/user_service.dart';
// import '../services/auth_service.dart';
// import 'create_user.dart'; // Importar la nueva pantalla
// import 'edit_user.dart';
// import 'login_screen.dart';

// COMENTADO: UserListScreen ya no se usa, ahora usamos ExpenseListScreen
class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pantalla Deshabilitada'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Esta pantalla ya no se usa',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Ahora usamos ExpenseListScreen',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}