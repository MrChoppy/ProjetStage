// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:projetdev/authentication.dart';
import 'package:projetdev/pages/login.dart';
import 'package:projetdev/pages/stages.dart';
import 'package:projetdev/pages/update.dart';

class MenuEtudiant extends StatefulWidget {
  const MenuEtudiant({super.key});

  @override
  _MenuEtudiantState createState() => _MenuEtudiantState();
}

class _MenuEtudiantState extends State<MenuEtudiant> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    const Stages(),
    const Update(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Connecte en tant qu\'utilisateur'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () async {
              await signOut();
              if (context.mounted) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const Login(),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Liste des stages',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Modifier profil',
          )
        ],
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: MenuEtudiant(),
  ));
}
