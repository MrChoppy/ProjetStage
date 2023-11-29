import 'package:flutter/material.dart';
import 'package:projetdev/authentication.dart';
import 'package:projetdev/pages/stages.dart';
import 'package:projetdev/pages/update.dart';
import 'package:projetdev/pages/map.dart';

class MenuEtudiant extends StatefulWidget {
  const MenuEtudiant({super.key});

  @override
  _MenuEtudiantState createState() => _MenuEtudiantState();
}

class _MenuEtudiantState extends State<MenuEtudiant> {
  int _currentIndex = 0;
  final List<Widget> _pages = [const Stages(), const Update(), const Map()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connecté en tant qu\'étudiant'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () async {
              await signOut(context);
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('Liste des stages'),
              onTap: () {
                setState(() {
                  _currentIndex = 0;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Modifier profil'),
              onTap: () {
                setState(() {
                  _currentIndex = 1;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: _pages[_currentIndex],
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: MenuEtudiant(),
  ));
}
