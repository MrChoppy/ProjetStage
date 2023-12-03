import 'package:flutter/material.dart';
import 'package:projetdev/authentication.dart';

class Soumissions extends StatefulWidget {
  const Soumissions({super.key});

  @override
  _SoumissionsState createState() => _SoumissionsState();
}

class _SoumissionsState extends State<Soumissions> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Soumissions'),
      ),
      body: FutureBuilder(
        future: getSoumissions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Erreur: ${snapshot.error}');
          } else {
            List<Map<String, dynamic>> soumissions =
                snapshot.data as List<Map<String, dynamic>>;
            return ListView.separated(
              itemCount: soumissions.length,
              separatorBuilder: (context, index) =>
                  const Divider(), // Ajoute une barre séparatrice entre chaque ListTile
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    soumissions[index]['compagnie'],
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 26),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Poste: ${soumissions[index]['poste']}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Statut: ${soumissions[index]['statut']}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
