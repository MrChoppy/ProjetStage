import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:projetdev/pages/update.dart';
import 'pages/home.dart';

Future<void> signUpWithEmailAndPasswordEtudiant(
    //AJOUTE: String prenom, String nom,  etc.
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
    User? user = FirebaseAuth.instance.currentUser;
    // Vérifier si l'utilisateur n'est pas nul
    print(user);
    if (user != null) {
      // Créer un document dans Firestore avec les données de l'utilisateur
      await FirebaseFirestore.instance.collection('etudiant').doc(user.uid).set({
        'email': email,
        'nom': nom,
        'prenom': prenom,
        'telephone': telephone,
        'adresse': adresse,
        'perms':"etudiant",
      });
    }
    //change de page
    if (context.mounted) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => const Update(),
      ));
    }
  } catch (e) {
    // Gérer les erreurs (par exemple, l'e-mail existe déjà)
    print('Erreur : $e');
  }
}

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
    User? user = FirebaseAuth.instance.currentUser;

    // Vérifier si l'utilisateur n'est pas nul
    if (user != null) {
      // Créer un document dans Firestore avec les données de l'employeur
      await FirebaseFirestore.instance.collection('employeur').doc(user.uid).set({
        'email': email,
        'nomEntreprise': nomEntreprise,
        'nomPersonneContact':nomPersonneContact,
        'prenomPersonneContact':prenomPersonneContact,
        'adresse':adresse,
        'telephone':telephone,
        'posteTelephonique':posteTelephonique,
        'perms':"employeur",
      });
    }
    //change de page
    if (context.mounted) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => const Update(),
      ));
    }
  } catch (e) {
    // Gérer les erreurs (par exemple, l'e-mail existe déjà)
    print('Erreur : $e');
  }
}





// Connecter un utilisateur existant
Future<void> signInWithEmailAndPassword(
    BuildContext context, String email, String password) async {
  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    //change de page
    if (context.mounted) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => const Update(),
      ));
    }
  } catch (e) {
    // Gérer les erreurs (par exemple, des identifiants invalides)
    print('Erreur : $e');
  }
}

// Déconnecter l'utilisateur
Future<void> signOut() async {
  await FirebaseAuth.instance.signOut();
}

// Vérifier si un utilisateur est authentifié
User? getCurrentUser() {
  return FirebaseAuth.instance.currentUser;
}
String getUserId(){
   User? user = getCurrentUser();
    String userId = user != null ? user.uid : '';
return userId;
}

Future<void> updateEtudiantInfo(String uid, Map<String, dynamic> newData) async {
  try {
    print("tesst");
    // Récupérer les données actuelles de l'etudiant
    DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.collection('etudiant').doc(uid).get();

    // Extraire les données actuelles
    Map<String, dynamic> currentData =
        snapshot.data() as Map<String, dynamic>;

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

Future<void> updateEmployeurInfo(String uid, Map<String, dynamic> newData) async {
  try {
    // Récupérer les données actuelles de l'employeur
    DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.collection('employeur').doc(uid).get();

    // Extraire les données actuelles
    Map<String, dynamic> currentData =
        snapshot.data() as Map<String, dynamic>;

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

Future<String> getUserPerms(String uid) async {
  try {
    // Check if the user's document exists in the 'employeur' collection
    
    DocumentSnapshot employerDoc =
        await FirebaseFirestore.instance.collection('employeur').doc(uid).get();
        
    // Check if the user's document exists in the 'etudiant' collection
    DocumentSnapshot studentDoc =
        await FirebaseFirestore.instance.collection('etudiant').doc(uid).get();

    // Determine permissions based on document existence
    if (employerDoc.exists) {
      return 'Employeur';
    } else if (studentDoc.exists) {
      return 'Étudiant';
    } else {
      // Handle the case where the user document doesn't exist in either collection
      return '';
    }
  } catch (e) {
    // Handle any errors that occur during the data retrieval
    print('Error fetching user permissions: $e');
    return '';
  }
}
