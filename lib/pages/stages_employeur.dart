import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'modifier_stage.dart';
import '/authentication.dart';

class StagesEmployeur extends StatefulWidget {
  const StagesEmployeur({super.key});

  @override
  _StagesEmployeurState createState() => _StagesEmployeurState();
}

class _StagesEmployeurState extends State<StagesEmployeur> {
  @override
  Widget build(BuildContext context) {
    User? user = getCurrentUser();
    if (user != null) {
      String userId = user.uid;

      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Liste de vos stages'),
        ),
        body: FutureBuilder<QuerySnapshot>(
          future: vueStagesEmployeur(userId), // Get stages de l'employeur
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Erreur : ${snapshot.error}');
            } else {
              final stages = snapshot.data!.docs;

              if (stages.isEmpty) {
                return const Center(
                  child: Text('Vous n\'avez aucun stage.'),
                );
              }

              return Center(
                child: SizedBox(
                  width: 400,
                  child: ListView.builder(
                    itemCount: stages.length,
                    itemBuilder: (context, index) {
                      final stage = stages[index];
                      final data = stage.data() as Map<String, dynamic>;

                      return Column(
                        children: [
                          ListTile(
                            title: Text(
                              data['poste'] ?? '',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              data['description'] ?? '',
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ModifierStage(stage: stage),
                                ),
                              );
                            },
                          ),
                          const Divider(
                            color: Colors.grey,
                            thickness: 1.0,
                          ),
                        ],
                      );
                    },
                  ),
                ),
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
