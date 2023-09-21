import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/authentication.dart';

class Stages extends StatefulWidget {
  const Stages({super.key});

  @override
  _StagesState createState() => _StagesState();
}

class _StagesState extends State<Stages> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Liste des Stages'),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: vueStages(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Erreur : ${snapshot.error}');
          } else {
            final stages = snapshot.data!.docs;

            if (stages.isEmpty) {
              return const Center(
                child: Text('Aucun stage disponible pour le moment.'),
              );
            }

            return ListView.builder(
              itemCount: stages.length,
              itemBuilder: (context, index) {
                final stage = stages[index];
                final data = stage.data() as Map<String, dynamic>;

                return FutureBuilder<Map<String, dynamic>>(
                  future: getEmployerInfo(data['employeurId']),
                  builder: (BuildContext context,
                      AsyncSnapshot<Map<String, dynamic>> employerSnapshot) {
                    if (employerSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (employerSnapshot.hasError) {
                      return Text('Erreur : ${employerSnapshot.error}');
                    } else {
                      final employerData = employerSnapshot.data;

                      return ListTile(
                        title: Text(data['title'] ?? ''),
                        subtitle: Text(data['description'] ?? ''),
                        // Add more details or actions as needed
                        trailing: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Email: ${employerData?['email']}',
                              style: const TextStyle(
                                fontSize: 16, // Adjust the font size here
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Phone: ${employerData?['telephone']}',
                              style: const TextStyle(
                                fontSize: 16, // Adjust the font size here
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
