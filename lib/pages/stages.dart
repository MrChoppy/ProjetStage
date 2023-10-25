import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/authentication.dart';

class Stages extends StatefulWidget {
  const Stages({super.key});

  @override
  _StagesState createState() => _StagesState();
}

class _StagesState extends State<Stages> {
  final TextEditingController _applicationMessageController =
      TextEditingController();

  void _showApplyDialog(
      Map<String, dynamic> stageData, Map<String, dynamic> employeurData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Détails du stage'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  "Nom de l'entreprise : ${employeurData?['nomEntreprise'] ?? ''}"),
              Text(
                  "Prénom personne contact : ${employeurData?['prenomPersonneContact'] ?? ''}"),
              Text(
                  "Nom personne contact : ${employeurData?['nomPersonneContact'] ?? ''}"),
              Text("Adresse : ${employeurData?['adresse'] ?? ''}"),
              Text("Téléphone : ${employeurData?['telephone'] ?? ''}"),
              Text(
                  "Poste téléphonique : ${employeurData?['posteTelephonique'] ?? ''}"),
              Text('Poste : ${stageData['poste'] ?? ''}'),
              Text('Description : ${stageData['description'] ?? ''}'),
              Text('Email de l\'employeur : ${employeurData?['email'] ?? ''}'),
              Text(
                  'Téléphone de l\'employeur : ${employeurData?['telephone'] ?? ''}'),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                User? user = getCurrentUser();
                if (user != null) {
                  String userId = user.uid;

                  String stageId = stageData['idStage'];
                  await FirebaseFirestore.instance
                      .collection('candidatures')
                      .add({
                    'etudiantId': userId, 
                    'stageId': stageId, 
                    'statut': 'En attente', 
                  });

                  Navigator.of(context).pop();
                } else {
                  print('**********');
                }
              },
              child: Text('POSTULER'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Liste des Stages'),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: vueStages(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Erreur : ${snapshot.error}');
          } else {
            final stages = snapshot.data!.docs;

            if (stages.isEmpty) {
              return const Center(
                child: Text('Aucun stage disponible pour le moment.'),
              );
            }

            return Center(
              child: SizedBox(
                width: 700,
                height: MediaQuery.of(context).size.height * 0.7,
                child: ListView.builder(
                  itemCount: stages.length,
                  itemBuilder: (context, index) {
                    final stage = stages[index];
                    final data = stage.data() as Map<String, dynamic>;

                    return FutureBuilder<Map<String, dynamic>>(
                      future: getEmployeurInfo(data['employeurId']),
                      builder: (BuildContext context,
                          AsyncSnapshot<Map<String, dynamic>>
                              employeurSnapshot) {
                        if (employeurSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (employeurSnapshot.hasError) {
                          return Text('Erreur : ${employeurSnapshot.error}');
                        } else {
                          final employeurData = employeurSnapshot.data;

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
                                trailing: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Email: ${employeurData?['email']}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Phone: ${employeurData?['telephone']}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  if (employeurData != null) {
                                    _showApplyDialog(data, employeurData);
                                  } else {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text('Erreur'),
                                          content: Text(
                                              'Les informations de l\'employeur ne sont plus disponibles.'),
                                          actions: [
                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.of(context)
                                                    .pop(); // Ferme le popup d'erreur.
                                              },
                                              child: Text('OK'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }
                                },
                              ),
                              const Divider(
                                color: Colors.grey,
                                thickness: 1.0,
                              ),
                            ],
                          );
                        }
                      },
                    );
                  },
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
