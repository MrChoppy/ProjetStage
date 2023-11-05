import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projetdev/authentication.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CandidaturesEmployeur extends StatefulWidget {
  @override
  _CandidaturesEmployeurState createState() => _CandidaturesEmployeurState();
}

class _CandidaturesEmployeurState extends State<CandidaturesEmployeur> {
  String? selectedStageId;
  List<QueryDocumentSnapshot>? stages;

  @override
  void initState() {
    super.initState();
    fetchEmployeurStages();
  }

  Future<void> fetchEmployeurStages() async {
    try {
      User? user = getCurrentUser();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Candidatures Employeur'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, 
          crossAxisAlignment:
              CrossAxisAlignment.center, 
          children: [
            DropdownButton<String>(
              value: selectedStageId,
              hint: Text('Sélectionner un stage'),
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
            SizedBox(height: 16), 
            FutureBuilder<QuerySnapshot>(
              future: getCandidaturesForStage(selectedStageId ?? ''),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Erreur : ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Text('Aucune candidature trouvée pour ce stage.');
                } else {
                  print("Candidatures: ${snapshot.data!.docs.length}");
                  return Expanded(
                    child: ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final candidatureData = snapshot.data!.docs[index]
                            .data() as Map<String, dynamic>;
                        print("Candidature $index: $candidatureData");

                        final etudiantId =
                            candidatureData['etudiantId'] as String;

                        return FutureBuilder<Map<String, dynamic>>(
                            future: getEtudiantInfo(etudiantId),
                            builder: (context, etudiantSnapshot) {
                              if (etudiantSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              } else if (etudiantSnapshot.hasError) {
                                return Text(
                                    'Erreur : ${etudiantSnapshot.error}');
                              } else {
                                final etudiantInfo =
                                    etudiantSnapshot.data ?? {};

                                return Column(
                                  children: [
                                    ListTile(
                                      title: Row(
                                        children: [
                                          Text(
                                              'Nom de l\'étudiant: ${etudiantInfo['nom'] ?? 'N/A'}'),
                                          SizedBox(width: 8),
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
                                        ],
                                      ),
                                    ),
                                    if (index < snapshot.data!.docs.length - 1)
                                      Divider(
                                          thickness: 1,
                                          color: Colors
                                              .grey), 
                                  ],
                                );
                              }
                              ;
                            });
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
