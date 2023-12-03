import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:projetdev/menus/menu_employeur.dart';
import 'package:projetdev/menus/menu_etudiant.dart';
import 'package:projetdev/pages/login.dart';

//
//
//  USERS
//
//

// Connecter un utilisateur existant
Future<bool> signInWithEmailAndPassword(
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
      if (context.mounted) {
        navigateBasedOnUserRole(userPerms, context);
      }
      return true;
    } else {
      print('User role not recognized.');
      return false;
    }
  } catch (e) {
    print('Erreur : $e');
    return false;
  }
}

// Déconnecter l'utilisateur
Future<void> signOut(BuildContext context) async {
  await FirebaseAuth.instance.signOut();
  if (context.mounted) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => const Login(),
    ));
  }
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
    DocumentSnapshot employeurDoc =
        await FirebaseFirestore.instance.collection('employeur').doc(uid).get();

    // Vérifie si le document de l'utilisateur existe dans la collection 'etudiant'
    DocumentSnapshot etudiantDoc =
        await FirebaseFirestore.instance.collection('etudiant').doc(uid).get();

    // Détermine les autorisations en fonction de l'existence du document
    if (employeurDoc.exists) {
      return 'Employeur';
    } else if (etudiantDoc.exists) {
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
  TextEditingController remarquesController,
  TextEditingController nomEntrepriseController,
  TextEditingController prenomPersonneContactController,
  TextEditingController nomPersonneContactController,
  TextEditingController posteTelephoniqueController,
) async {
  String uid = getUserId();

  if (userType == 'Étudiant') {
    // Get le snapshot de l'étudiant
    DocumentSnapshot etudiantSnapshot =
        await FirebaseFirestore.instance.collection('etudiant').doc(uid).get();

    if (etudiantSnapshot.exists) {
      // Get les données du snapshot
      Map<String, dynamic> etudiantData =
          etudiantSnapshot.data() as Map<String, dynamic>;

      // Update les contrôleurs avec les données de l'étudiant
      nomController.text = etudiantData['nom'] ?? '';
      prenomController.text = etudiantData['prenom'] ?? '';
      adresseController.text = etudiantData['adresse'] ?? '';
      telephoneController.text = etudiantData['telephone'] ?? '';
      remarquesController.text = etudiantData['remarques'] ?? '';
    }
  } else if (userType == 'Employeur') {
    // Get le snapshot de l'employeur
    DocumentSnapshot employeurSnapshot =
        await FirebaseFirestore.instance.collection('employeur').doc(uid).get();

    if (employeurSnapshot.exists) {
      // Récupérer les données du snapshot
      Map<String, dynamic> employeurData =
          employeurSnapshot.data() as Map<String, dynamic>;

      // Update les contrôleurs avec les données de l'employeur
      nomEntrepriseController.text = employeurData['nomEntreprise'] ?? '';
      prenomPersonneContactController.text =
          employeurData['prenomPersonneContact'] ?? '';
      nomPersonneContactController.text =
          employeurData['nomPersonneContact'] ?? '';
      adresseController.text = employeurData['adresse'] ?? '';
      telephoneController.text = employeurData['telephone'] ?? '';
      posteTelephoniqueController.text =
          employeurData['posteTelephonique'] ?? '';
    }
  }
}

//
//
//  VUES
//
//
void navigateBasedOnUserRole(String userPerms, BuildContext context) {
  switch (userPerms) {
    case 'Étudiant':
      navigateToVueEtudiant(context);
      break;
    case 'Employeur':
      navigateToVueEmployeur(context);
      break;
    default:
      print('User role pas reconu.');
  }
}

void navigateToVueEtudiant(BuildContext context) {
  Navigator.of(context).pushReplacement(
    MaterialPageRoute(
      builder: (context) => const MenuEtudiant(),
    ),
  );
}

void navigateToVueEmployeur(BuildContext context) {
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
  String remarques,
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
        'remarques': remarques,
        'adresse': adresse,
        'perms': "etudiant",
      });
      //change de page
      String userId = user.uid;
      String userPerms = await getUserPerms(userId);
      if (context.mounted) {
        navigateBasedOnUserRole(userPerms, context);
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

Future<Map<String, dynamic>> getEmployeurInfo(String employeurId) async {
  try {
    DocumentSnapshot employeurSnapshot = await FirebaseFirestore.instance
        .collection('employeur')
        .doc(employeurId)
        .get();

    if (employeurSnapshot.exists) {
      return employeurSnapshot.data() as Map<String, dynamic>;
    } else {
      return {}; // Return map vide si l'employeur n'existe pas
    }
  } catch (e) {
    print('Error fetching employeur info: $e');
    return {};
  }
}

Future<String> getAdresseEtudiant(String uid) async {
  try {
    DocumentSnapshot studentDoc =
        await FirebaseFirestore.instance.collection('etudiant').doc(uid).get();

    if (studentDoc.exists) {
      Map<String, dynamic> studentData =
          studentDoc.data() as Map<String, dynamic>;
      return studentData['adresse'] ?? '';
    } else {
      return '';
    }
  } catch (e) {
    print('Error retrieving student address: $e');
    return '';
  }
}
//
//
//  EMPLOYEUR
//
//

Future<void> signUpWithEmailAndPasswordEmployeur(
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
      String userId = user.uid;
      String userPerms = await getUserPerms(userId);
      if (context.mounted) {
        navigateBasedOnUserRole(userPerms, context);
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
    String poste,
    String compagnie,
    String adresse,
    String dateDebut,
    String dateFin,
    String description) async {
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
          'poste': poste,
          'compagnie': compagnie,
          'adresse': adresse,
          'dateDebut': dateDebut,
          'dateFin': dateFin,
          'description': description,
          'statut': true
        });
      } else {
        print('Vous n\'avez pas l\'autorisation d\'ajouter des stages.');
      }
    }
  } catch (e) {
    print('Erreur lors de lajout du stage : $e');
  }
}

Future<void> getStages() async {
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

        List<String> titles = [];
        for (QueryDocumentSnapshot doc in stagesQuery.docs) {
          titles.add(doc['poste'] as String);
        }
      } else {
        print('Vous n\'avez pas l\'autorisation de consulter les stages.');
      }
    }
  } catch (e) {
    print('Erreur lors du chargement des titres des stages : $e');
  }
}

Future<Map<String, dynamic>> getEtudiantInfo(String etudiantId) async {
  try {
    DocumentSnapshot etudiantSnapshot = await FirebaseFirestore.instance
        .collection('etudiant')
        .doc(etudiantId)
        .get();

    if (etudiantSnapshot.exists) {
      return etudiantSnapshot.data() as Map<String, dynamic>;
    } else {
      // Retourner un map vide si l'étudiant n'existe pas
      return {};
    }
  } catch (e) {
    print(
        'Erreur lors de la récupération des informations de l\'étudiant : $e');
    return {};
  }
}

Future<QuerySnapshot<Object?>> getCandidaturesForStage(String stageId) async {
  try {
    return await FirebaseFirestore.instance
        .collection('candidatures')
        .where('stageId', isEqualTo: stageId)
        .get();
  } catch (e) {
    throw Exception('Erreur lors de la récupération des candidatures : $e');
  }
}

Stream<QuerySnapshot> vueStagesEmployeur(String uid) {
  try {
    return FirebaseFirestore.instance
        .collection('stages')
        .where('employeurId', isEqualTo: uid)
        .snapshots();
  } catch (e) {
    throw Exception('Erreur lors de la recuperation des stages: $e');
  }
}

Future<void> updateStageInfo(
    String stageId, Map<String, dynamic> newData) async {
  try {
    await FirebaseFirestore.instance
        .collection('stages')
        .doc(stageId)
        .update(newData);
  } catch (e) {
    print('Error updating stage info: $e');
    throw Exception('Error updating stage info: $e');
  }
}

Future<bool> hasStudentApplied(String studentId, String stageId) async {
  QuerySnapshot query = await FirebaseFirestore.instance
      .collection('candidatures')
      .where('etudiantId', isEqualTo: studentId)
      .where('stageId', isEqualTo: stageId)
      .get();

  return query.docs.isNotEmpty;
}

Future<void> updateStage(
    String stageId,
    String posteController,
    String compagnieController,
    String adresseController,
    String dateDebutController,
    String dateFinController,
    String descriptionController) async {
  try {
    Map<String, dynamic> newData = {
      'poste': posteController,
      'compagnie': compagnieController,
      'adresse': adresseController,
      'dateDebut': dateDebutController,
      'dateFin': dateFinController,
      'description': descriptionController,
    };

    await updateStageInfo(stageId, newData);
  } catch (e) {
    print('Error updating stage: $e');
  }
}

Future<void> deleteStage(String stageId) async {
  try {
    // Supprime d'abord toutes les candidatures associées au stage
    await deleteCandidaturesForStage(stageId);

    // Ensuite, supprime le stage lui-même
    await deleteStageInfo(stageId);
  } catch (e) {
    print('Error deleting stage: $e');
  }
}

Future<void> deleteCandidaturesForStage(String stageId) async {
  try {
    final QuerySnapshot<Object?> candidaturesQuery = await FirebaseFirestore
        .instance
        .collection('candidatures')
        .where('stageId', isEqualTo: stageId)
        .get();

    for (QueryDocumentSnapshot<Object?> doc in candidaturesQuery.docs) {
      final String candidatureId = doc.id;
      await deleteCandidatureInfo(candidatureId);
    }
  } catch (e) {
    print('Error deleting candidatures for stage: $e');
  }
}

Future<void> deleteCandidatureInfo(String candidatureId) async {
  try {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    final CollectionReference candidaturesCollection =
        firestore.collection('candidatures');
    final DocumentReference candidatureDocument =
        candidaturesCollection.doc(candidatureId);

    await candidatureDocument.delete();

    print('Candidature with ID $candidatureId has been successfully deleted.');
  } catch (e) {
    print('Error deleting candidature: $e');
  }
}

Future<void> deleteStageInfo(String stageId) async {
  try {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    final CollectionReference stagesCollection = firestore.collection('stages');
    final DocumentReference stageDocument = stagesCollection.doc(stageId);

    await stageDocument.delete();

    print('Stage with ID $stageId has been successfully deleted.');
  } catch (e) {
    print('Error deleting stage: $e');
  }
}

Future<List<Map<String, dynamic>>> getSoumissions() async {
  try {
    User? utilisateur = getCurrentUser();
    if (utilisateur != null) {
      String idUtilisateur = utilisateur.uid;
      QuerySnapshot soumissionsQuery = await FirebaseFirestore.instance
          .collection('candidatures')
          .where('etudiantId', isEqualTo: idUtilisateur)
          .get();

      List<Map<String, dynamic>> soumissions = [];
      for (QueryDocumentSnapshot candidature in soumissionsQuery.docs) {
        String stageId = candidature['stageId'];
        Map<String, dynamic> stageInfo = await getStageInfo(stageId);
        soumissions.add({
          'stageId': stageId,
          'compagnie': stageInfo['compagnie'],
          'poste': stageInfo['poste'],
          'statut': candidature['statut'],
        });
      }

      return soumissions;
    } else {
      throw Exception(
          'Utilisateur non trouvé lors de la récupération des soumissions.');
    }
  } catch (e) {
    print('Erreur lors de la récupération des soumissions : $e');
    throw Exception('Erreur lors de la récupération des soumissions : $e');
  }
}

Future<Map<String, dynamic>> getStageInfo(String stageId) async {
  try {
    DocumentSnapshot stageSnapshot = await FirebaseFirestore.instance
        .collection('stages')
        .doc(stageId)
        .get();

    if (stageSnapshot.exists) {
      return stageSnapshot.data() as Map<String, dynamic>;
    } else {
      return {};
    }
  } catch (e) {
    print('Erreur lors de la récupération des informations du stage : $e');
    return {};
  }
}
