import 'package:flutter/material.dart';
import 'login.dart';
import '/authentication.dart';

class Signup extends StatefulWidget {
  const Signup({Key? key}) : super(key: key);

  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final TextEditingController nomController = TextEditingController();
  final TextEditingController prenomController = TextEditingController();
  final TextEditingController adresseController = TextEditingController();
  final TextEditingController telephoneController = TextEditingController();

  final TextEditingController nomEntrepriseController = TextEditingController();
  final TextEditingController prenomPersonneContactController = TextEditingController();
  final TextEditingController nomPersonneContactController = TextEditingController();
  final TextEditingController posteTelephoniqueController = TextEditingController();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String selectedUserType = 'Étudiant'; // Default selected user type

  final List<String> userTypes = ['Étudiant', 'Employeur']; // Dropdown options

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
             Container(
              width: 400, // Set the desired width
              child: DropdownButtonFormField<String>(
                value: selectedUserType,
                onChanged: (newValue) {
                  setState(() {
                    selectedUserType = newValue!;
                  });
                },
                items: userTypes.map((String userType) {
                  return DropdownMenuItem<String>(
                    value: userType,
                    child: Text(userType),
                  );
                }).toList(),
                decoration: const InputDecoration(
                  labelText: 'Je suis un :',
                ),
              ),
            ),
            Visibility(
              visible: selectedUserType == 'Employeur',
              child: Container(
                width: 400,
                child: TextField(
                  controller: nomEntrepriseController,
                  decoration: const InputDecoration(labelText: "Nom de l'entreprise"),
                ),
              ),
            ),
             Visibility(
              visible: selectedUserType == 'Employeur',
              child: Container(
                width: 400,
                child: TextField(
                  controller: prenomPersonneContactController,
                  decoration: const InputDecoration(labelText: "Prénom de la personne responsable"),
                ),
              ),
            ),
             Visibility(
              visible: selectedUserType == 'Employeur',
              child: Container(
                width: 400,
                child: TextField(
                  controller: nomPersonneContactController,
                  decoration: const InputDecoration(labelText: "Nom de la personne responsable"),
                ),
              ),
            ),
             Visibility(
              visible: selectedUserType == 'Étudiant',
              child: Container(
                width: 400,
                child: TextField(
                  controller: prenomController,
                  decoration: const InputDecoration(labelText: 'Prénom'),
                ),
              ),
            ),
            Visibility(
              visible: selectedUserType == 'Étudiant',
              child: Container(
                width: 400,
                child: TextField(
                  controller: nomController,
                  decoration: const InputDecoration(labelText: 'Nom'),
                ),
              ),
            ),
            Container(
              width: 400, // Set the desired width
              child: TextField(
                controller: adresseController,
                decoration: const InputDecoration(labelText: 'Adresse complète'),
              ),
            ),
             Container(
              width: 400, // Set the desired width
              child: TextField(
                controller: telephoneController,
                decoration: const InputDecoration(labelText: 'Numéro de téléphone'),
              ),
            ),
          Visibility(
              visible: selectedUserType == 'Employeur',
              child: Container(
                width: 400,
                child: TextField(
                  controller: posteTelephoniqueController,
                  decoration: const InputDecoration(labelText: "Poste téléphonique"),
                ),
              ),
            ),

              Container(
              width: 400,
              height: 150,
              margin: const EdgeInsets.only(top: 20.0),
              child: Column(
                children: [                  
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                    ),
                  ),
                  TextField(
                    controller: passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Mot de passe',
                    ),
                    obscureText: true,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: () {
                if (selectedUserType == "Étudiant") {
                  signUpWithEmailAndPasswordEtudiant(
                  context,
                  emailController.text,
                  passwordController.text,
                  nomController.text,
                  prenomController.text,
                  telephoneController.text,
                  adresseController.text
                  );
                } else if (selectedUserType == "Employeur") {
                  signUpWithEmailAndPasswordEmployeur(
                    context,
                    emailController.text,
                    passwordController.text,
                    nomEntrepriseController.text,
                    nomPersonneContactController.text,
                    prenomPersonneContactController.text,
                    adresseController.text,
                    telephoneController.text,
                    posteTelephoniqueController.text
                  );
                }
                },
              child: const Text("S'inscrire"),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                // Navigate to the login page when the button is pressed
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => Login(),
                ));
              },
              child: const Text('Déja inscrit(e)? Se connecter'),
            ),
          ],
        ),
      ),
    );
  }
}