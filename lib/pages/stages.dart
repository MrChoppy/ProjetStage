import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projetdev/authentication.dart';
import 'package:intl/intl.dart';

class Stages extends StatefulWidget {
  const Stages({super.key});

  @override
  _StagesState createState() => _StagesState();
}

class _StagesState extends State<Stages> {
  void _showApplyDialog(stageId, stageData, employeurData) async {
    User? user = getCurrentUser();
    if (user != null) {
      String userId = user.uid;
      bool hasApplied = await hasStudentApplied(userId, stageId);
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Détails du stage'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Poste:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  stageData['poste'] ?? '',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Description:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Container(
                  constraints: const BoxConstraints(
                    maxWidth: 700,
                  ),
                  child: Text(
                    stageData['description'] ?? '',
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.justify,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Adresse:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  stageData['adresse'] ?? '',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () async {
                  if (hasApplied) {
                    QuerySnapshot query = await FirebaseFirestore.instance
                        .collection('candidatures')
                        .where('etudiantId', isEqualTo: userId)
                        .where('stageId', isEqualTo: stageId)
                        .get();

                    if (query.docs.isNotEmpty) {
                      String dateCandidature = query.docs[0]['dateCandidature'];
                      if (!context.mounted) return;
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Erreur'),
                            content: Text(
                                'Vous avez déjà postulé le $dateCandidature.'),
                            actions: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  } else {
                    DateTime currentDateTime = DateTime.now();
                    String currentDate =
                        DateFormat('y/MM/dd HH:mm').format(currentDateTime);

                    await FirebaseFirestore.instance
                        .collection('candidatures')
                        .add({
                      'etudiantId': userId,
                      'stageId': stageId,
                      'statut': 'En attente',
                      'dateCandidature': currentDate,
                    });
                    if (!context.mounted) return;

                    Navigator.of(context).pop();

                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Succès'),
                          content: const Text(
                              'Votre candidature a été enregistrée avec succès.'),
                          actions: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                child: const Text('POSTULER'),
              ),
            ],
          );
        },
      );
    } else {
      print('**********');
    }
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
                    String stageId = stage.id;
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
                                    _showApplyDialog(
                                        stageId, stage, employeurData);
                                  } else {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Erreur'),
                                          content: const Text(
                                              "Les informations de l'employeur ne sont plus disponibles."),
                                          actions: [
                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('OK'),
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
