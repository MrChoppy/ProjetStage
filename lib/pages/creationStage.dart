import 'package:flutter/material.dart';
import '/authentication.dart';

class CreationStage extends StatefulWidget {
  const CreationStage({super.key});

  @override
  _CreationStageState createState() => _CreationStageState();
}

class _CreationStageState extends State<CreationStage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController durationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Ajouter un Stage'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: titleController, // Store the entered text
                decoration: const InputDecoration(labelText: 'Titre'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descriptionController, // Store the entered text
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: locationController, // Store the entered text
                decoration: const InputDecoration(labelText: 'Location'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: durationController, // Store the entered text
                decoration: const InputDecoration(labelText: 'Durée'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Retrieve the text from the controllers and pass it to addStage
                  String title = titleController.text;
                  String description = descriptionController.text;
                  String location = locationController.text;
                  String duration = durationController.text;

                  addStage(context, title, description, location, duration);
                },
                child: const Text('Ajouter le Stage'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
