import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '/authentication.dart';

class StagesEmployeur extends StatefulWidget {
  const StagesEmployeur({super.key});

  @override
  _StagesEmployeurState createState() => _StagesEmployeurState();
}

class _StagesEmployeurState extends State<StagesEmployeur> {
  late TextEditingController posteController;
  late TextEditingController compagnieController;
  late TextEditingController adresseController;
  late TextEditingController dateDebutController;
  late TextEditingController dateFinController;
  late TextEditingController descriptionController;

  String successMessage = '';

  late DateTime selectedDate;

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController dateController,
  ) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
        String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
        dateController.text = formattedDate;
      });
    }
  }

  void _showModifDialog(stageData) {
    posteController = TextEditingController(text: stageData['poste'] ?? '');
    compagnieController = TextEditingController(text: stageData['compagnie'] ?? '');
    adresseController = TextEditingController(text: stageData['adresse'] ?? '');
    dateDebutController = TextEditingController(text: stageData['dateDebut'] ?? '');
    dateFinController = TextEditingController(text: stageData['dateFin'] ?? '');
    descriptionController = TextEditingController(text: stageData['description'] ?? '');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Détails du stage'),
          content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  controller: posteController,
                  decoration: const InputDecoration(labelText: 'Poste du stagiaire : '),
                ),
                TextFormField(
                  controller: compagnieController,
                  decoration: const InputDecoration(labelText: 'Compagnie : '),
                ),
                TextFormField(
                  controller: adresseController,
                  decoration: const InputDecoration(labelText: 'Adresse : '),
                ),
                TextFormField(
                  controller: dateDebutController,
                  decoration: const InputDecoration(labelText: 'Date du début'),
                  onTap: () => _selectDate(context, dateDebutController),
                ),
                TextFormField(
                  controller: dateFinController,
                  decoration: const InputDecoration(labelText: 'Date de fin'),
                  onTap: () => _selectDate(context, dateFinController),
                ),
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                      labelText: 'Description des tâches :'),
                  maxLines: 3,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    updateStage(
                      stageData.id,
                      posteController.text,
                      compagnieController.text,
                      adresseController.text,
                      dateDebutController.text,
                      dateFinController.text,
                      descriptionController.text,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Update réussi!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                    Navigator.of(context).pop();
                  },
                  child: const Text('Enregistrer les modifications'),
                ),
                ElevatedButton(
                  onPressed: () {
                    deleteStage(stageData.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Vous avez supprimé le stage avec succès!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                    Navigator.of(context).pop();
                  },
                  child: const Text('Supprimer le stage'),
                ),
                ElevatedButton(
                  onPressed: () {
                    fetchStudentNames(stageData.id);
                  },
                  child: const Text('Afficher les candidats'),
                ),
              ]),
        );
      },
    );
  }

  // Function to fetch student names and display in an alert
void fetchStudentNames(String internshipId) {
  FirebaseFirestore.instance
      .collection('candidatures')
      .where('stageId', isEqualTo: internshipId)
      .get()
      .then((QuerySnapshot querySnapshot) {
    List<String> studentIds = querySnapshot.docs.map((doc) => doc['etudiantId'] as String).toList();

    FirebaseFirestore.instance
        .collection('etudiant')
        .where(FieldPath.documentId, whereIn: studentIds)
        .get()
        .then((QuerySnapshot studentSnapshot) {
      List<String> studentNames = studentSnapshot.docs
          .map((doc) => '${doc['prenom']} ${doc['nom']}')
          .toList();

      // Display student names in an alert
      String studentNamesText = studentNames.join('\n');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Étudiants ayant postulé au stage'),
            content: Text(studentNamesText),
            actions: <Widget>[
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the alert
                },
                child: const Text('Fermer'),
              ),
            ],
          );
        },
      );
    });
  });
}

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
        body: StreamBuilder<QuerySnapshot>(
          stream: vueStagesEmployeur(userId), // Get stages de l'employeur
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
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
                              if (stage.id != "") {
                                _showModifDialog(stage);
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Erreur'),
                                      content: const Text(
                                          'Les informations de l\'employeur ne sont plus disponibles.'),
                                      actions: [
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.of(context).pop(); // Ferme le popup d'erreur.
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
