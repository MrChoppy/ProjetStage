import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:projetdev/menus/menuEmployeur.dart';
import 'package:projetdev/menus/menuEtudiant.dart';

//
//
//  USERS
//
//

// Connecter un utilisateur existant
Future<void> signInWithEmailAndPassword(
    BuildContext context, String email, String password) async {
  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    User? user = getCurrentUser();

    if (user != null) {
      String userId = user.uid;
      String userPerms = await getUserPerms(userId);
      print(userPerms);
      if (context.mounted) {
        _navigateBasedOnUserRole(userPerms, context);
      }
    } else {
      print('User role not recognized.');
    }
  } catch (e) {
    print('Erreur : $e');
  }
}

// Déconnecter l'utilisateur
Future<void> signOut() async {
  await FirebaseAuth.instance.signOut();
}

User? getCurrentUser() {
  return FirebaseAuth.instance.currentUser;
}

String getUserId() {
  User? user = getCurrentUser();
  String userId = user != null ? user.uid : '';
  return userId;
}

Future<String> getUserPerms(String uid) async {
  try {
    // Vérifie si le document de l'utilisateur existe dans la collection 'employeur'
    DocumentSnapshot employerDoc =
        await FirebaseFirestore.instance.collection('employeur').doc(uid).get();

    // Vérifie si le document de l'utilisateur existe dans la collection 'etudiant'
    DocumentSnapshot studentDoc =
        await FirebaseFirestore.instance.collection('etudiant').doc(uid).get();

    // Détermine les autorisations en fonction de l'existence du document
    if (employerDoc.exists) {
      return 'Employeur';
    } else if (studentDoc.exists) {
      return 'Étudiant';
    } else {
      // Gère le cas où le document de l'utilisateur n'existe pas dans l'une ou l'autre collection
      return '';
    }
  } catch (e) {
    print(
        'Erreur lors de la récupération des autorisations de l\'utilisateur : $e');
    return '';
  }
}

Future<void> updateUserTextFields(
  String userType,
  TextEditingController nomController,
  TextEditingController prenomController,
  TextEditingController adresseController,
  TextEditingController telephoneController,
  TextEditingController nomEntrepriseController,
  TextEditingController prenomPersonneContactController,
  TextEditingController nomPersonneContactController,
  TextEditingController posteTelephoniqueController,
) async {
  String uid = getUserId();

  if (userType == 'Étudiant') {
    DocumentSnapshot studentSnapshot =
        await FirebaseFirestore.instance.collection('etudiant').doc(uid).get();

    if (studentSnapshot.exists) {
      Map<String, dynamic> studentData =
          studentSnapshot.data() as Map<String, dynamic>;
      nomController.text = studentData['nom'] ?? '';
      prenomController.text = studentData['prenom'] ?? '';
      adresseController.text = studentData['adresse'] ?? '';
      telephoneController.text = studentData['telephone'] ?? '';
    }
  } else if (userType == 'Employeur') {
    DocumentSnapshot employerSnapshot =
        await FirebaseFirestore.instance.collection('employeur').doc(uid).get();

    if (employerSnapshot.exists) {
      Map<String, dynamic> employerData =
          employerSnapshot.data() as Map<String, dynamic>;
      nomEntrepriseController.text = employerData['nomEntreprise'] ?? '';
      prenomPersonneContactController.text =
          employerData['prenomPersonneContact'] ?? '';
      nomPersonneContactController.text =
          employerData['nomPersonneContact'] ?? '';
      adresseController.text = employerData['adresse'] ?? '';
      telephoneController.text = employerData['telephone'] ?? '';
      posteTelephoniqueController.text =
          employerData['posteTelephonique'] ?? '';
    }
  }
}

//
//
//  VUES
//
//
void _navigateBasedOnUserRole(String userPerms, BuildContext context) {
  switch (userPerms) {
    case 'Étudiant':
      _navigateToVueEtudiant(context);
      break;
    case 'Employeur':
      _navigateToVueEmployeur(context);
      break;
    default:
      print('User role not recognized.');
  }
}

void _navigateToVueEtudiant(BuildContext context) {
  Navigator.of(context).pushReplacement(
    MaterialPageRoute(
      builder: (context) => const MenuEtudiant(),
    ),
  );
}

void _navigateToVueEmployeur(BuildContext context) {
  Navigator.of(context).pushReplacement(
    MaterialPageRoute(
      builder: (context) => const MenuEmployeur(),
    ),
  );
}

//
//
//  ETUDIANT
//
//

Future<void> signUpWithEmailAndPasswordEtudiant(
  BuildContext context,
  String email,
  String password,
  String nom,
  String prenom,
  String telephone,
  String adresse,
) async {
  try {
    // Créer un nouveau compte utilisateur
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    // Récupérer l'utilisateur actuellement authentifié
    User? user = getCurrentUser();
    // Vérifier si l'utilisateur n'est pas nul
    if (user != null) {
      // Créer un document dans Firestore avec les données de l'utilisateur
      await FirebaseFirestore.instance
          .collection('etudiant')
          .doc(user.uid)
          .set({
        'email': email,
        'nom': nom,
        'prenom': prenom,
        'telephone': telephone,
        'adresse': adresse,
        'perms': "etudiant",
      });
      //change de page
      if (context.mounted) {
        String userId = user.uid;
        String userPerms = await getUserPerms(userId);
        _navigateBasedOnUserRole(userPerms, context);
      }
    }
  } catch (e) {
    // Gérer les erreurs (par exemple, l'e-mail existe déjà)
    print('Erreur : $e');
  }
}

Future<void> updateEtudiantInfo(
    String uid, Map<String, dynamic> newData) async {
  try {
    // Récupérer les données actuelles de l'etudiant
    DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.collection('etudiant').doc(uid).get();

    // Extraire les données actuelles
    Map<String, dynamic> currentData = snapshot.data() as Map<String, dynamic>;

    // Comparer les nouvelles données avec les données actuelles et mettre à jour uniquement si non vide
    Map<String, dynamic> updatedData = {};
    newData.forEach((key, value) {
      if (value != null && value != '' && currentData[key] != value) {
        updatedData[key] = value;
      }
    });

    // Mettre à jour uniquement les champs non vides et modifiés dans la base de données
    if (updatedData.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('etudiant')
          .doc(uid)
          .update(updatedData);
    }
  } catch (e) {
    print('Erreur lors de la mise à jour des informations : $e');
  }
}

Future<QuerySnapshot> vueStages() async {
  try {
    return await FirebaseFirestore.instance.collection('stages').get();
  } catch (e) {
    throw Exception('Error fetching stages: $e');
  }
}

Future<Map<String, dynamic>> getEmployerInfo(String employerId) async {
  try {
    DocumentSnapshot employerSnapshot = await FirebaseFirestore.instance
        .collection('employeur')
        .doc(employerId)
        .get();

    if (employerSnapshot.exists) {
      return employerSnapshot.data() as Map<String, dynamic>;
    } else {
      return {}; // Return an empty map if the employer doesn't exist
    }
  } catch (e) {
    print('Error fetching employer info: $e');
    return {};
  }
}

//
//
//  EMPLOYEUR
//
//

Future<void> signUpWithEmailAndPasswordEmployeur(
  //AJOUTE: String prenom, String nom,  etc.
  BuildContext context,
  String email,
  String password,
  String nomEntreprise,
  String nomPersonneContact,
  String prenomPersonneContact,
  String adresse,
  String telephone,
  String posteTelephonique,
) async {
  try {
    // Créer un nouveau compte utilisateur
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    // Récupérer l'utilisateur actuellement authentifié
    User? user = getCurrentUser();

    // Vérifier si l'utilisateur n'est pas nul
    if (user != null) {
      // Créer un document dans Firestore avec les données de l'employeur
      await FirebaseFirestore.instance
          .collection('employeur')
          .doc(user.uid)
          .set({
        'email': email,
        'nomEntreprise': nomEntreprise,
        'nomPersonneContact': nomPersonneContact,
        'prenomPersonneContact': prenomPersonneContact,
        'adresse': adresse,
        'telephone': telephone,
        'posteTelephonique': posteTelephonique,
        'perms': "employeur",
      });
      //change de page
      if (context.mounted) {
        String userId = user.uid;
        String userPerms = await getUserPerms(userId);
        _navigateBasedOnUserRole(userPerms, context);
      }
    }
  } catch (e) {
    // Gérer les erreurs (par exemple, l'e-mail existe déjà)
    print('Erreur : $e');
  }
}

Future<void> updateEmployeurInfo(
    String uid, Map<String, dynamic> newData) async {
  try {
    // Récupérer les données actuelles de l'employeur
    DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.collection('employeur').doc(uid).get();

    // Extraire les données actuelles
    Map<String, dynamic> currentData = snapshot.data() as Map<String, dynamic>;

    // Comparer les nouvelles données avec les données actuelles et mettre à jour uniquement si non vide
    Map<String, dynamic> updatedData = {};
    newData.forEach((key, value) {
      if (value != null && value != '' && currentData[key] != value) {
        updatedData[key] = value;
      }
    });

    // Mettre à jour uniquement les champs non vides et modifiés dans la base de données
    if (updatedData.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('employeur')
          .doc(uid)
          .update(updatedData);
    }
  } catch (e) {
    print('Erreur lors de la mise à jour des informations : $e');
  }
}

Future<void> addStage(
  BuildContext context,
  String title,
  String description,
  String location,
  String duration,
) async {
  try {
    User? user = getCurrentUser();
    if (user != null) {
      String userId = user.uid;

      // Vérifie si l'utilisateur est un "employeur"
      String userPerms = await getUserPerms(userId);
      if (userPerms == "Employeur") {
        // Ajoute le stage à la base de données dans la collection "stages"
        await FirebaseFirestore.instance.collection('stages').add({
          'employeurId': userId,
          'title': title,
          'description': description,
          'location': location,
          'duration': duration,
          //autre
        });
      } else {
        print('Vous n\'avez pas l\'autorisation d\'ajouter des stages.');
      }
    }
  } catch (e) {
    print('Erreur lors de lajout du stage : $e');
  }
}

Future<QuerySnapshot> vueStagesEmployeur(String uid) async {
  try {
    return await FirebaseFirestore.instance
        .collection('stages')
        .where('employeurId', isEqualTo: uid)
        .get();
  } catch (e) {
    throw Exception('Error fetching stages: $e');
  }
}
