import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/authentication.dart'; // Import your authentication.dart file

class StagesEmployeur extends StatefulWidget {
  const StagesEmployeur({super.key});

  @override
  _StagesEmployeurState createState() => _StagesEmployeurState();
}

class _StagesEmployeurState extends State<StagesEmployeur> {
  @override
  Widget build(BuildContext context) {
    User? user = getCurrentUser(); // Get the current user
    if (user != null) {
      String userId = user.uid;

      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Liste des Stages de l\'employeur'),
        ),
        body: FutureBuilder<QuerySnapshot>(
          future: vueStagesEmployeur(
              userId), // Fetch stages for the current employer
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator(); // Show a loading indicator while fetching data
            } else if (snapshot.hasError) {
              return Text('Erreur : ${snapshot.error}');
            } else {
              // Data has been fetched successfully
              final stages = snapshot.data!.docs;

              if (stages.isEmpty) {
                return const Center(
                  child: Text('Aucun stage disponible pour le moment.'),
                );
              }

              return ListView.builder(
                itemCount: stages.length,
                itemBuilder: (context, index) {
                  // Customize how each stage is displayed
                  final stage = stages[index];
                  final data = stage.data() as Map<String, dynamic>;

                  return ListTile(
                    title: Text(data['title'] ?? ''),
                    subtitle: Text(data['description'] ?? ''),
                    // Add more details or actions as needed
                  );
                },
              );
            }
          },
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Liste des Stages'),
        ),
        body: const Center(
          child: Text('Utilisateur non connecté.'),
        ),
      );
    }
  }
}
