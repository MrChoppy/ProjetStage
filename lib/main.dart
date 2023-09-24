import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:projetdev/firebase_options.dart';
import 'package:projetdev/authentication.dart';
import 'package:projetdev/menus/menu_employeur.dart';
import 'package:projetdev/menus/menu_etudiant.dart';
import './pages/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot<User?> userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            // Renvoyer un indicateur de chargement pendant la vérification de l'état de l'utilisateur
            return const CircularProgressIndicator();
          } else {
            // Vérifier si l'utilisateur est authentifié ou non
            final user = userSnapshot.data;
            if (user == null) {
              // Si non authentifié, naviguer vers la page de login
              return const Login();
            } else {
              // Si authentifié, déterminer le rôle de l'utilisateur et envoyer vers la bonne page
              final userId = user.uid;
              return FutureBuilder<String>(
                future: getUserPerms(userId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Erreur : ${snapshot.error}');
                  } else {
                    final userRole = snapshot.data;
                    if (userRole == 'Employeur') {
                      // Naviguer vers la page Employeur
                      return const MenuEmployeur();
                    } else if (userRole == 'Étudiant') {
                      // Naviguer vers la page Étudiant
                      return const MenuEtudiant();
                    } else {
                      // Gérer les rôles d'utilisateur non reconnus
                      return const Text('Rôle de l\'utilisateur non reconnu');
                    }
                  }
                },
              );
            }
          }
        },
      ),
      title: 'Stage',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
    );
  }
}
