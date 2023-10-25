import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../authentication.dart';

class ModifierStage extends StatefulWidget {
  final DocumentSnapshot stage;

  const ModifierStage({required this.stage, Key? key}) : super(key: key);

  @override
  _ModifierStageState createState() => _ModifierStageState();
}

class _ModifierStageState extends State<ModifierStage> {
  late TextEditingController posteController;
  late TextEditingController compagnieController;
  late TextEditingController adresseController;
  late TextEditingController dateDebutController;
  late TextEditingController dateFinController;
  late TextEditingController descriptionController;
  String successMessage = '';
  bool statut = true;

  @override
  void initState() {
    super.initState();
    final data = widget.stage.data() as Map<String, dynamic>;

    posteController = TextEditingController(text: data['poste'] ?? '');
    compagnieController = TextEditingController(text: data['compagnie'] ?? '');
    adresseController = TextEditingController(text: data['adresse'] ?? '');
    dateDebutController = TextEditingController(text: data['dateDebut'] ?? '');
    dateFinController = TextEditingController(text: data['dateFin'] ?? '');
    descriptionController =
        TextEditingController(text: data['description'] ?? '');
    statut = data['statut'];
  }

  @override
  void dispose() {
    posteController.dispose();
    compagnieController.dispose();
    adresseController.dispose();
    dateDebutController.dispose();
    dateFinController.dispose();
    descriptionController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier le stage'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            navigateToVueEmployeur(context);
          },
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(
                width: 400,
                child: TextField(
                  controller: posteController,
                  decoration: const InputDecoration(labelText: 'Poste'),
                ),
              ),
              SizedBox(
                width: 400,
                child: TextField(
                  controller: compagnieController,
                  decoration: const InputDecoration(labelText: 'Compagnie'),
                ),
              ),
              SizedBox(
                width: 400,
                child: TextField(
                  controller: adresseController,
                  decoration: const InputDecoration(labelText: 'Adresse'),
                ),
              ),
              SizedBox(
                width: 400,
                child: TextField(
                  controller: dateDebutController,
                  decoration: const InputDecoration(labelText: 'Date de début'),
                ),
              ),
              SizedBox(
                width: 400,
                child: TextField(
                  controller: dateFinController,
                  decoration: const InputDecoration(labelText: 'Date de fin'),
                ),
              ),
              SizedBox(
                width: 400,
                child: TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
              ),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Statut'),
                    const SizedBox(
                        width: 20), // Add some space between text and switch
                    Switch(
                      value: statut,
                      activeColor: const Color.fromARGB(255, 65, 0, 125),
                      onChanged: (bool value) {
                        setState(() {
                          statut = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  updateStage(
                    widget.stage.id,
                    posteController.text,
                    compagnieController.text,
                    adresseController.text,
                    dateDebutController.text,
                    dateFinController.text,
                    descriptionController.text,
                  );
                  setState(() {
                    successMessage = 'Update réussi!';
                  });
                },
                child: const Text('Enregistrer les modifications'),
              ),
              Text(
                successMessage,
                style: const TextStyle(
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
