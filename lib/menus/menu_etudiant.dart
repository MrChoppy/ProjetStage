import 'package:flutter/material.dart';
import 'package:projetdev/authentication.dart';
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
        title: const Text('Connecté en tant qu\'étudiant'),
        actions: [
          IconButton(
              icon: const Icon(Icons.exit_to_app),
              onPressed: () async {
                await signOut(context);
              }),
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
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Liste des stages',
          ),
          BottomNavigationBarItem(
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
