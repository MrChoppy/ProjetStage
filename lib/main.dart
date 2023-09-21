import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:projetdev/firebase_options.dart';
import 'package:projetdev/authentication.dart';
import 'package:projetdev/menus/menuEmployeur.dart';
import 'package:projetdev/menus/menuEtudiant.dart';
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
            // Return a loading indicator while checking the user's state
            return const CircularProgressIndicator();
          } else {
            // Check if the user is authenticated or not
            final user = userSnapshot.data;
            if (user == null) {
              // If not authenticated, navigate to the login page
              return const Login();
            } else {
              // If authenticated, determine the user's role and navigate accordingly
              final userId = user.uid;
              return FutureBuilder<String>(
                future: getUserPerms(
                    userId), // Replace with your function to get user role
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Erreur : ${snapshot.error}');
                  } else {
                    final userRole = snapshot.data;
                    if (userRole == 'Employeur') {
                      // Navigate to the Employeur page
                      return const MenuEmployeur();
                    } else if (userRole == 'Étudiant') {
                      // Navigate to the Étudiant page
                      return const MenuEtudiant();
                    } else {
                      // Handle unrecognized user roles
                      return const Text('User role not recognized');
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
