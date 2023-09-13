import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '/authentication.dart';
import 'login.dart';

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
  final Future<String> userType = getUserPerms(getUserId()) ; 
  
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
              visible: userType == 'Employeur',
              child: Container(
                width: 400,
                child: TextField(
                  controller: nomEntrepriseController,
                  decoration: const InputDecoration(labelText: "Nom de l'entreprise"),
                ),
              ),
            ),
             Visibility(
              visible: userType == 'Employeur',
              child: Container(
                width: 400,
                child: TextField(
                  controller: prenomPersonneContactController,
                  decoration: const InputDecoration(labelText: "Prénom de la personne responsable"),
                ),
              ),
            ),
             Visibility(
              visible: userType == 'Employeur',
              child: Container(
                width: 400,
                child: TextField(
                  controller: nomPersonneContactController,
                  decoration: const InputDecoration(labelText: "Nom de la personne responsable"),
                ),
              ),
            ),
             Visibility(
              visible: userType == 'Étudiant',
              child: Container(
                width: 400,
                child: TextField(
                  controller: prenomController,
                  decoration: const InputDecoration(labelText: 'Prénom'),
                ),
              ),
            ),
            Visibility(
              visible: userType == 'Étudiant',
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
              visible: userType == 'Employeur',
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
                final userTypeValue = await userType;
                if (userTypeValue == "Étudiant") {
                  
                  updateEtudiantInfo(
                    getUserId(),
                    {
                      'nom': nomController.text,
                      'prenom': prenomController.text,
                      'telephone': telephoneController.text,
                      'adresse': adresseController.text,
                    },
                );
                } else if (userTypeValue == "Employeur") {
                  updateEmployeurInfo(
                      getUserId(),
                      {
                        'nomEntreprise': nomEntrepriseController.text,
                        'nomPersonneContact': nomPersonneContactController.text,
                        'prenomPersonneContact': prenomPersonneContactController.text,
                        'adresse': adresseController.text,
                        'telephone': telephoneController.text,
                        'posteTelephonique': posteTelephoniqueController.text,
                      },
                    );
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