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
  final TextEditingController remarquesController = TextEditingController();
  final TextEditingController nomEntrepriseController = TextEditingController();
  final TextEditingController prenomPersonneContactController =
      TextEditingController();
  final TextEditingController nomPersonneContactController =
      TextEditingController();
  final TextEditingController posteTelephoniqueController =
      TextEditingController();

  User? user = getCurrentUser();
  late Future<String> userType;
  String? userTypeValue;
  String successMessage = '';
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    userType = getUserPerms(getUserId());

    userTypeValue = null;

    userType.then((value) async {
      setState(() {
        userTypeValue = value;
      });

      await updateUserTextFields(
          userTypeValue!,
          nomController,
          prenomController,
          adresseController,
          telephoneController,
          remarquesController,
          nomEntrepriseController,
          prenomPersonneContactController,
          nomPersonneContactController,
          posteTelephoniqueController);
    });
  }

  bool isPhoneValid(String phoneNumber) {
    final phoneRegex = RegExp(r'^\d{3}-\d{3}-\d{4}$');
    if (!phoneRegex.hasMatch(phoneNumber)) {
      setState(() {
        errorMessage =
            "Numéro de téléphone non valide. Doit avoir la syntaxe suivante : 123-456-7890";
      });
      return false;
    } else {
      setState(() {
        errorMessage = "";
      });
      return true;
    }
  }

  bool isAdresseValid(adresse_) {
    final String adresse = adresse_;

    if (adresse.isEmpty) {
      setState(() {
        errorMessage = 'Veuillez entrer une adresse.';
        successMessage = '';
      });
      return false;
    }

    final List<String> addressComponents = adresse.split(' ');

    if (addressComponents.length < 3) {
      setState(() {
        errorMessage =
            'Adresse invalide. Veuillez inclure le numéro, la rue et la ville au minimum.';
        successMessage = '';
      });
      return false;
    }

    final String numero = addressComponents[0].trim();

    if (int.tryParse(numero) == null) {
      setState(() {
        errorMessage =
            'Le numéro dans l\'adresse doit être composé uniquement de chiffres.';
        successMessage = '';
      });
      return false;
    }

    setState(() {
      errorMessage = '';
    });
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "Modification de profil",
          style: TextStyle(color: Colors.black),
        ),
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
              child: SizedBox(
                width: 400,
                child: TextField(
                  controller: nomEntrepriseController,
                  decoration:
                      const InputDecoration(labelText: "Nom de l'entreprise"),
                ),
              ),
            ),
            Visibility(
              visible: userTypeValue == 'Employeur',
              child: SizedBox(
                width: 400,
                child: TextField(
                  controller: prenomPersonneContactController,
                  decoration: const InputDecoration(
                      labelText: "Prénom de la personne responsable"),
                ),
              ),
            ),
            Visibility(
              visible: userTypeValue == 'Employeur',
              child: SizedBox(
                width: 400,
                child: TextField(
                  controller: nomPersonneContactController,
                  decoration: const InputDecoration(
                      labelText: "Nom de la personne responsable"),
                ),
              ),
            ),
            Visibility(
              visible: userTypeValue == 'Étudiant',
              child: SizedBox(
                width: 400,
                child: TextField(
                  controller: prenomController,
                  decoration: const InputDecoration(labelText: 'Prénom'),
                ),
              ),
            ),
            Visibility(
              visible: userTypeValue == 'Étudiant',
              child: SizedBox(
                width: 400,
                child: TextField(
                  controller: nomController,
                  decoration: const InputDecoration(labelText: 'Nom'),
                ),
              ),
            ),
            SizedBox(
              width: 400,
              child: TextField(
                controller: adresseController,
                decoration:
                    const InputDecoration(labelText: 'Adresse complète'),
              ),
            ),
            SizedBox(
              width: 400,
              child: TextFormField(
                controller: telephoneController,
                decoration:
                    const InputDecoration(labelText: 'Numéro de téléphone'),
              ),
            ),
            Visibility(
              visible: userTypeValue == 'Étudiant',
              child: SizedBox(
                width: 400,
                child: TextField(
                  controller: remarquesController,
                  decoration: const InputDecoration(labelText: "Remarques"),
                ),
              ),
            ),
            Visibility(
              visible: userTypeValue == 'Employeur',
              child: SizedBox(
                width: 400,
                child: TextField(
                  controller: posteTelephoniqueController,
                  decoration:
                      const InputDecoration(labelText: "Poste téléphonique"),
                ),
              ),
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: () async {
                if (userTypeValue == "Étudiant") {
                  String uid = getUserId();
                  Map<String, dynamic> newData = {
                    'nom': nomController.text,
                    'prenom': prenomController.text,
                    'adresse': adresseController.text,
                    'telephone': telephoneController.text,
                    'remarques': remarquesController.text
                  };
                  if (isPhoneValid(telephoneController.text) &&
                      isAdresseValid(adresseController.text)) {
                    await updateEtudiantInfo(uid, newData);
                  }
                } else if (userTypeValue == "Employeur") {
                  String uid = getUserId();
                  Map<String, dynamic> newData = {
                    'nomEntreprise': nomEntrepriseController.text,
                    'prenomPersonneContact':
                        prenomPersonneContactController.text,
                    'nomPersonneContact': nomPersonneContactController.text,
                    'adresse': adresseController.text,
                    'telephone': telephoneController.text,
                    'posteTelephonique': posteTelephoniqueController.text,
                  };
                  if (isPhoneValid(telephoneController.text) &&
                      isAdresseValid(adresseController.text)) {
                    await updateEtudiantInfo(uid, newData);
                  }
                }
                // success message
                if (isPhoneValid(telephoneController.text) &
                    isAdresseValid(adresseController.text)) {
                  setState(() {
                    successMessage = 'Update reussi!';
                    errorMessage = "";
                  });
                }
              },
              child: const Text("Update"),
            ),

            // success message
            Text(
              successMessage,
              style: const TextStyle(
                color: Colors.green,
              ),
            ),
            Text(
              errorMessage,
              style: const TextStyle(
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
