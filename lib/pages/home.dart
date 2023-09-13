import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/authentication.dart';
import 'login.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    User? user = getCurrentUser();

    // Contrôleur de texte pour le champ du nom
    final TextEditingController nomController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Accueil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Bienvenue, ${user?.email ?? 'Utilisateur'}!',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            // Champ de texte pour entrer le nouveau nom
            TextFormField(
              controller: nomController,
              decoration: const InputDecoration(
                labelText: 'Changer le nom',
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                // Obtenez le nouveau nom à partir du champ de texte
                String newName = nomController.text.trim();

                // Vérifiez si le nouveau nom n'est pas vide
                if (newName.isNotEmpty) {
                  // Appelez la fonction updateUserInfo pour mettre à jour le nom
                  await updateEtudiantInfo(user!.uid, {'nom': newName});
                  // Effacez le champ de texte
                  nomController.clear();
                }
              },
              child: const Text('Mettre à jour le nom'),
            ),
          ],
        ),
      ),
    );
  }
}
