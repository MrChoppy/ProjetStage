import 'package:flutter/material.dart';
import 'package:projetdev/authentication.dart';
import 'package:projetdev/pages/candidaturesEmployeur.dart';
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
    const CandidaturesEmployeur(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('Liste de vos stages'),
              onTap: () {
                setState(() {
                  _currentIndex = 0;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.add_box),
              title: const Text('Ajouter un stage'),
              onTap: () {
                setState(() {
                  _currentIndex = 1;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Modifier profil'),
              onTap: () {
                setState(() {
                  _currentIndex = 2;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.supervisor_account),
              title: const Text('Candidatures des étudiants'),
              onTap: () {
                setState(() {
                  _currentIndex = 3;
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
    home: MenuEmployeur(),
  ));
}
