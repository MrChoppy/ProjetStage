import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projetdev/authentication.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class CandidaturesEmployeur extends StatefulWidget {
  const CandidaturesEmployeur({super.key});

  @override
  _CandidaturesEmployeurState createState() => _CandidaturesEmployeurState();
}

class _CandidaturesEmployeurState extends State<CandidaturesEmployeur> {
  String? selectedStageId;
  List<QueryDocumentSnapshot>? stages;

  StreamController<List<QueryDocumentSnapshot>> candidaturesStreamController =
      StreamController<List<QueryDocumentSnapshot>>();

  @override
  void initState() {
    super.initState();
    fetchEmployeurStages();
  }

  @override
  void dispose() {
    candidaturesStreamController.close();
    super.dispose();
  }

  Future<void> fetchEmployeurStages() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String userId = user.uid;

        String userPerms = await getUserPerms(userId);
        if (userPerms == 'Employeur') {
          QuerySnapshot stagesQuery = await FirebaseFirestore.instance
              .collection('stages')
              .where('employeurId', isEqualTo: userId)
              .get();

          setState(() {
            stages = stagesQuery.docs;
          });
        } else {
          print('Vous n\'avez pas l\'autorisation de consulter les stages.');
        }
      }
    } catch (e) {
      print('Erreur lors du chargement des titres des stages : $e');
    }
  }

  Stream<QuerySnapshot> getCandidaturesForStage(String stageId) {
    return FirebaseFirestore.instance
        .collection('candidatures')
        .where('stageId', isEqualTo: stageId)
        .snapshots();
  }

  Future<Map<String, dynamic>> getEtudiantInfo(String etudiantId) async {
    try {
      DocumentSnapshot etudiantSnapshot = await FirebaseFirestore.instance
          .collection('etudiant')
          .doc(etudiantId)
          .get();

      if (etudiantSnapshot.exists) {
        return etudiantSnapshot.data() as Map<String, dynamic>;
      }
    } catch (e) {
      print(
          'Erreur lors de la récupération des informations de l\'étudiant : $e');
    }
    return {}; // Return an empty map in case of an error
  }

  Future<void> updateCandidatureStatus(
      String candidatureId, String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('candidatures')
          .doc(candidatureId)
          .update({'statut': newStatus});

      print('Statut de la candidature mis à jour avec succès.');
    } catch (e) {
      print('Erreur lors de la mise à jour du statut de la candidature : $e');
    }
  }

  Future<void> showStatusDialog(String candidatureId) async {
    String? selectedStatus;

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Changer le statut de la candidature'),
          children: [
            ListTile(
              title: const Text('En attente'),
              onTap: () {
                Navigator.pop(context, 'En attente');
              },
            ),
            ListTile(
              title: const Text('Convoqué à une entrevue'),
              onTap: () {
                Navigator.pop(context, 'Convoqué à une entrevue');
              },
            ),
            ListTile(
              title: const Text('Refusé'),
              onTap: () {
                Navigator.pop(context, 'Refusé');
              },
            ),
          ],
        );
      },
    ).then((value) {
      if (value != null) {
        // Mettez à jour le statut dans la base de données
        updateCandidatureStatus(candidatureId, value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Candidatures Employeur'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            DropdownButton<String>(
              value: selectedStageId,
              hint: const Text('Sélectionner un stage'),
              onChanged: (String? newStageId) {
                setState(() {
                  selectedStageId = newStageId;
                });
              },
              items: stages?.map((stage) {
                    return DropdownMenuItem<String>(
                      value: stage.id,
                      child: Text(stage['poste'] as String),
                    );
                  }).toList() ??
                  [],
            ),
            const SizedBox(height: 16),
            StreamBuilder<QuerySnapshot>(
              stream: getCandidaturesForStage(selectedStageId ?? ''),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Erreur : ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Text(
                      'Aucune candidature trouvée pour ce stage.');
                } else {
                  candidaturesStreamController.add(snapshot.data!.docs);

                  return Expanded(
                    child: ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final candidatureData = snapshot.data!.docs[index]
                            .data() as Map<String, dynamic>;
                        final etudiantId =
                            candidatureData['etudiantId'] as String;
                        final candidatureId = snapshot.data!.docs[index].id;

                        return FutureBuilder<Map<String, dynamic>>(
                          future: getEtudiantInfo(etudiantId),
                          builder: (context, etudiantSnapshot) {
                            if (etudiantSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (etudiantSnapshot.hasError) {
                              return Text('Erreur : ${etudiantSnapshot.error}');
                            } else {
                              final etudiantInfo = etudiantSnapshot.data ?? {};

                              return Column(
                                children: [
                                  ListTile(
                                    title: Row(
                                      children: [
                                        Text(
                                            'Nom de l\'étudiant: ${etudiantInfo['nom'] ?? 'N/A'}'),
                                        const SizedBox(width: 8),
                                        Text(
                                            '${etudiantInfo['prenom'] ?? 'N/A'}'),
                                      ],
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            'Email de l\'étudiant: ${etudiantInfo['email'] ?? 'N/A'}'),
                                        Text(
                                            'Remarques: ${etudiantInfo['remarques'] ?? 'N/A'}'),
                                        Text(
                                            'Date de postulation: ${candidatureData['dateCandidature'] ?? 'N/A'}'),
                                        Text(
                                            'Statut: ${candidatureData['statut'] ?? 'N/A'}'),
                                      ],
                                    ),
                                    onTap: () {
                                      showStatusDialog(candidatureId);
                                    },
                                  ),
                                  if (index < snapshot.data!.docs.length - 1)
                                    const Divider(
                                        thickness: 1, color: Colors.grey),
                                ],
                              );
                            }
                          },
                        );
                      },
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
