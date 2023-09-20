import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/authentication.dart';

class VueStages extends StatefulWidget {
  const VueStages({super.key});

  @override
  _VueStagesState createState() => _VueStagesState();
}

class _VueStagesState extends State<VueStages> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des Stages'),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: vueStages(), // Use the new function to fetch stages
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator(); // Show a loading indicator while fetching data
          } else if (snapshot.hasError) {
            return Text('Erreur : ${snapshot.error}');
          } else {
            // Data has been fetched successfully
            final stages = snapshot.data!.docs;

            if (stages.isEmpty) {
              return Center(
                child: Text('Aucun stage disponible pour le moment.'),
              );
            }

            return ListView.builder(
              itemCount: stages.length,
              itemBuilder: (context, index) {
                // Customize how each stage is displayed
                final stage = stages[index];
                final data = stage.data() as Map<String, dynamic>;

                return ListTile(
                  title: Text(data['title'] ?? ''),
                  subtitle: Text(data['description'] ?? ''),
                  // Add more details or actions as needed
                );
              },
            );
          }
        },
      ),
    );
  }
}
