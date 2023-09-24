import 'package:flutter/material.dart';
import 'package:projetdev/authentication.dart';
import 'package:projetdev/pages/creationStage.dart';
import 'package:projetdev/pages/stagesEmployeur.dart';
import 'package:projetdev/pages/update.dart';

class MenuEmployeur extends StatefulWidget {
  const MenuEmployeur({super.key});

  @override
  _MenuEmployeurState createState() => _MenuEmployeurState();
}

class _MenuEmployeurState extends State<MenuEmployeur> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    const StagesEmployeur(),
    const CreationStage(),
    const Update(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Connecté en tant qu\'employeur'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () async {
              await signOut(context);
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
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Liste de vos stages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box),
            label: 'Ajouter un stage',
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
    home: MenuEmployeur(),
  ));
}
