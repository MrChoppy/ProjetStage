import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/authentication.dart';
import 'stage_details.dart';

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

            return Center(
              child: SizedBox(
                width: 700,
                height: MediaQuery.of(context).size.height * 0.7,
                child: ListView.builder(
                  itemCount: stages.length,
                  itemBuilder: (context, index) {
                    final stage = stages[index];
                    final data = stage.data() as Map<String, dynamic>;

                    return FutureBuilder<Map<String, dynamic>>(
                      future: getEmployeurInfo(data['employeurId']),
                      builder: (BuildContext context,
                          AsyncSnapshot<Map<String, dynamic>>
                              employeurSnapshot) {
                        if (employeurSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (employeurSnapshot.hasError) {
                          return Text('Erreur : ${employeurSnapshot.error}');
                        } else {
                          final employeurData = employeurSnapshot.data ?? {};

                          return Column(
                            children: [
                              ListTile(
                                title: Text(
                                  data['poste'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  data['description'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => StageDetails(
                                        stageData: data,
                                        employerData: employeurData,
                                      ),
                                    ),
                                  );
                                },
                                trailing: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Email: ${employeurData['email']}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Phone: ${employeurData['telephone']}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(
                                color: Colors.grey,
                                thickness: 1.0,
                              ),
                            ],
                          );
                        }
                      },
                    );
                  },
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
