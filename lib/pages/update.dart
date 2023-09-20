import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '/authentication.dart';

class Update extends StatefulWidget {
  const Update({Key? key}) : super(key: key);

  @override
  _UpdateState createState() => _UpdateState();
}

class _UpdateState extends State<Update> {
  final TextEditingController nomController = TextEditingController();
  final TextEditingController prenomController = TextEditingController();
  final TextEditingController adresseController = TextEditingController();
  final TextEditingController telephoneController = TextEditingController();

  final TextEditingController nomEntrepriseController = TextEditingController();
  final TextEditingController prenomPersonneContactController = TextEditingController();
  final TextEditingController nomPersonneContactController = TextEditingController();
  final TextEditingController posteTelephoniqueController = TextEditingController();

  User? user = getCurrentUser();
  late Future<String> userType;
  String? userTypeValue; 

  @override
  void initState() {
    super.initState();
    userType = getUserPerms(getUserId());

    userTypeValue = null;

    userType.then((value) {
      setState(() {
        userTypeValue = value; 
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("S'inscrire", style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Bienvenue, ${user?.email ?? 'Utilisateur'}!',
              style: const TextStyle(fontSize: 20),
            ),
            Visibility(
              visible: userTypeValue == 'Employeur',
              child: Container(
                width: 400,
                child: TextField(
                  controller: nomEntrepriseController,
                  decoration: const InputDecoration(labelText: "Nom de l'entreprise"),
                ),
              ),
            ),
            Visibility(
              visible: userTypeValue == 'Employeur',
              child: Container(
                width: 400,
                child: TextField(
                  controller: prenomPersonneContactController,
                  decoration: const InputDecoration(labelText: "Prénom de la personne responsable"),
                ),
              ),
            ),
            Visibility(
              visible: userTypeValue == 'Employeur',
              child: Container(
                width: 400,
                child: TextField(
                  controller: nomPersonneContactController,
                  decoration: const InputDecoration(labelText: "Nom de la personne responsable"),
                ),
              ),
            ),
            Visibility(
              visible: userTypeValue == 'Étudiant',
              child: Container(
                width: 400,
                child: TextField(
                  controller: prenomController,
                  decoration: const InputDecoration(labelText: 'Prénom'),
                ),
              ),
            ),
            Visibility(
              visible: userTypeValue == 'Étudiant',
              child: Container(
                width: 400,
                child: TextField(
                  controller: nomController,
                  decoration: const InputDecoration(labelText: 'Nom'),
                ),
              ),
            ),
            Container(
              width: 400,
              child: TextField(
                controller: adresseController,
                decoration: const InputDecoration(labelText: 'Adresse complète'),
              ),
            ),
            Container(
              width: 400,
              child: TextField(
                controller: telephoneController,
                decoration: const InputDecoration(labelText: 'Numéro de téléphone'),
              ),
            ),
            Visibility(
              visible: userTypeValue == 'Employeur',
              child: Container(
                width: 400,
                child: TextField(
                  controller: posteTelephoniqueController,
                  decoration: const InputDecoration(labelText: "Poste téléphonique"),
                ),
              ),
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: () async {
                if (userTypeValue == "Étudiant") {
                  // Update student info
                  String uid = getUserId();
                  Map<String, dynamic> newData = {
                    'nom': nomController.text,
                    'prenom': prenomController.text,
                    'adresse': adresseController.text,
                    'telephone': telephoneController.text,
                  };
                  await updateEtudiantInfo(uid, newData);
                } else if (userTypeValue == "Employeur") {
                  // Update employer info
                  String uid = getUserId();
                  Map<String, dynamic> newData = {
                    'nomEntreprise': nomEntrepriseController.text,
                    'prenomPersonneContact': prenomPersonneContactController.text,
                    'nomPersonneContact': nomPersonneContactController.text,
                    'adresse': adresseController.text,
                    'telephone': telephoneController.text,
                    'posteTelephonique': posteTelephoniqueController.text,
                  };
                  await updateEmployeurInfo(uid, newData);
                }
              },
              child: const Text("Update"),
            ),
          ],
        ),
      ),
    );
  }
}
