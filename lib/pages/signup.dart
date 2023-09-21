// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'login.dart'; // Import your login screen
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
  final TextEditingController prenomPersonneContactController =
      TextEditingController();
  final TextEditingController nomPersonneContactController =
      TextEditingController();
  final TextEditingController posteTelephoniqueController =
      TextEditingController();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String selectedUserType = 'Étudiant'; // Default selected user type
  String? errorText;
  final List<String> userTypes = ['Étudiant', 'Employeur']; // Dropdown options

  bool isEmailValid(String email) {
    // Change this regular expression as needed for your specific validation
    final emailRegex = RegExp(r'^\d{7}@cmontmorency\.qc\.ca$');
    return emailRegex.hasMatch(email);
  }

  bool isEmailEmployeurValid(String email) {
    final emailEmployeurRegEx = RegExp(r'^.*@.*\..*$');
    return emailEmployeurRegEx.hasMatch(email);
  }

  bool isPhoneValid(String phoneNumber) {
    final phoneRegex = RegExp(r'^\d{3}-\d{3}-\d{4}$');
    return phoneRegex.hasMatch(phoneNumber);
  }

  @override
  Widget build(BuildContext context) {
    // Create a FocusNode for the email field
    final emailFocusNode = FocusNode();

    // Define a GlobalKey for the form to reset it later
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
                decoration: InputDecoration(
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
                  decoration: InputDecoration(labelText: "Nom de l'entreprise"),
                ),
              ),
            ),
            Visibility(
              visible: selectedUserType == 'Employeur',
              child: Container(
                width: 400,
                child: TextField(
                  controller: prenomPersonneContactController,
                  decoration: InputDecoration(
                      labelText: "Prénom de la personne responsable"),
                ),
              ),
            ),
            Visibility(
              visible: selectedUserType == 'Employeur',
              child: Container(
                width: 400,
                child: TextField(
                  controller: nomPersonneContactController,
                  decoration: InputDecoration(
                      labelText: "Nom de la personne responsable"),
                ),
              ),
            ),
            Visibility(
              visible: selectedUserType == 'Étudiant',
              child: Container(
                width: 400,
                child: TextField(
                  controller: prenomController,
                  decoration: InputDecoration(labelText: 'Prénom'),
                ),
              ),
            ),
            Visibility(
              visible: selectedUserType == 'Étudiant',
              child: Container(
                width: 400,
                child: TextField(
                  controller: nomController,
                  decoration: InputDecoration(labelText: 'Nom'),
                ),
              ),
            ),
            Container(
              width: 400, // Set the desired width
              child: TextField(
                controller: adresseController,
                decoration:
                    const InputDecoration(labelText: 'Adresse complète'),
              ),
            ),
            Container(
              width: 400, // Set the desired width
              child: TextField(
                controller: telephoneController,
                decoration:
                    const InputDecoration(labelText: 'Numéro de téléphone'),
              ),
            ),
            Visibility(
              visible: selectedUserType == 'Employeur',
              child: Container(
                width: 400,
                child: TextField(
                  controller: posteTelephoniqueController,
                  decoration: InputDecoration(labelText: "Poste téléphonique"),
                ),
              ),
            ),
            Container(
              width: 400,
              height: 150,
              margin: EdgeInsets.only(top: 1.0),
              child: Column(
                children: [
                  TextFormField(
                    controller: emailController,
                    focusNode: emailFocusNode,
                    decoration: InputDecoration(
                      labelText: 'Email',
                    ),
                  ),
                  TextField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: 'Mot de passe',
                    ),
                    obscureText: true,
                  ),
                ],
              ),
            ),
            //const SizedBox(height: 25),
            if (errorText != null)
              Container(
                margin:
                    const EdgeInsets.only(top: 2.0), // Add margin to the top
                child: Text(
                  errorText!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ElevatedButton(
              onPressed: () {
                final String email = emailController.text;
                final String phoneNumber = telephoneController.text;

                if (selectedUserType == 'Employeur' &&
                    nomEntrepriseController.text.isEmpty) {
                  setState(() {
                    errorText = "Le champ 'Nom de l'entreprise' est requis.";
                  });
                } else if (selectedUserType == 'Employeur' &&
                    prenomPersonneContactController.text.isEmpty) {
                  setState(() {
                    errorText =
                        "Le champ 'Prénom de la personne responsable' est requis.";
                  });
                } else if (selectedUserType == 'Employeur' &&
                    nomPersonneContactController.text.isEmpty) {
                  setState(() {
                    errorText =
                        "Le champ 'Nom de la personne responsable' est requis.";
                  });
                } else if (selectedUserType == 'Étudiant' &&
                    prenomController.text.isEmpty) {
                  setState(() {
                    errorText = "Le champ 'Prénom' est requis.";
                  });
                } else if (selectedUserType == 'Étudiant' &&
                    nomController.text.isEmpty) {
                  setState(() {
                    errorText = "Le champ 'Nom' est requis.";
                  });
                } else if (adresseController.text.isEmpty) {
                  setState(() {
                    errorText = "Le champ 'Adresse complète' est requis.";
                  });
                } else if (!isPhoneValid(phoneNumber)) {
                  setState(() {
                    errorText =
                        "Numéro de téléphone non valide. Doit avoir la syntaxe suivante : 123-456-7890";
                  });
                } else if (selectedUserType == "Employeur" &&
                    posteTelephoniqueController.text.isEmpty) {
                  setState(() {
                    errorText = "Le champ 'Poste téléphonique' est requis.";
                  });
                } else if (selectedUserType == 'Étudiant' &&
                    !isEmailValid(email)) {
                  setState(() {
                    errorText =
                        "Email non valide. L'email doit avoir la syntaxe suivante : 1234567@cmontmorency.qc.ca.";
                  });
                } else if (passwordController.text.isEmpty) {
                  setState(() {
                    errorText = "Le champ 'Mot de passe' est requis.";
                  });
                } else if (selectedUserType == "Employeur" &&
                    !isEmailEmployeurValid(email)) {
                  setState(() {
                    errorText =
                        "Email non valide. L'email doit contenir un @ et un .";
                  });
                } else {
                  setState(() {
                    errorText =
                        null; // Reset errorText when all conditions are met
                  });
                  // Perform sign-up here
                  if (selectedUserType == "Étudiant" &&
                      isEmailValid(email) &&
                      isPhoneValid(phoneNumber)) {
                    signUpWithEmailAndPasswordEtudiant(
                        context,
                        emailController.text,
                        passwordController.text,
                        nomController.text,
                        prenomController.text,
                        telephoneController.text,
                        adresseController.text);
                  } else if (selectedUserType == "Employeur" &&
                      isPhoneValid(phoneNumber) &&
                      isEmailEmployeurValid(email)) {
                    signUpWithEmailAndPasswordEmployeur(
                        context,
                        emailController.text,
                        passwordController.text,
                        nomEntrepriseController.text,
                        nomPersonneContactController.text,
                        prenomPersonneContactController.text,
                        adresseController.text,
                        telephoneController.text,
                        posteTelephoniqueController.text);
                  }
                }
              },
              child: const Text("S'inscrire"),
            ),

            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                // Navigate to the login page when the button is pressed
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => const Login(),
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
