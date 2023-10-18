import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../authentication.dart';
import 'package:intl/intl.dart';

class ModifierStage extends StatefulWidget {
  final DocumentSnapshot stage;

  const ModifierStage({required this.stage, Key? key}) : super(key: key);

  @override
  _ModifierStageState createState() => _ModifierStageState();
}

class _ModifierStageState extends State<ModifierStage> {
  late TextEditingController posteController;
  late TextEditingController compagnieController;
  late TextEditingController adresseController;
  late TextEditingController dateDebutController;
  late TextEditingController dateFinController;
  late TextEditingController descriptionController;
  String successMessage = '';

  late DateTime selectedDate;

 Future<void> _selectDate(
    BuildContext context,
    TextEditingController dateController,
  ) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
        String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
        dateController.text = formattedDate;
      });
    }
  }
  @override
  void initState() {
    super.initState();
    final data = widget.stage.data() as Map<String, dynamic>;

    posteController = TextEditingController(text: data['poste'] ?? '');
    compagnieController = TextEditingController(text: data['compagnie'] ?? '');
    adresseController = TextEditingController(text: data['adresse'] ?? '');
    dateDebutController = TextEditingController(text: data['dateDebut'] ?? '');
    dateFinController = TextEditingController(text: data['dateFin'] ?? '');
    descriptionController =
        TextEditingController(text: data['description'] ?? '');
  }

  @override
  void dispose() {
    posteController.dispose();
    compagnieController.dispose();
    adresseController.dispose();
    dateDebutController.dispose();
    dateFinController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Modifier le stage'),
        ),
  body: Center(
        child: SizedBox(
          width: 400.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: posteController,
                decoration:
                    const InputDecoration(labelText: 'Poste du stagiaire : '),
              ),
              TextFormField(
                controller: compagnieController,
                decoration: const InputDecoration(labelText: 'Compagnie : '),
              ),
              TextFormField(
                controller: adresseController,
                decoration: const InputDecoration(labelText: 'Adresse : '),
              ),
              TextFormField(
                controller: dateDebutController,
                decoration: const InputDecoration(labelText: 'Date du debut'),
                onTap: () => _selectDate(context, dateDebutController),
              ),
              TextFormField(
                controller: dateFinController,
                decoration: const InputDecoration(labelText: 'Date de fin'),
                onTap: () => _selectDate(context, dateFinController),
              ),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(
                    labelText: 'Description des tâches :'),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  updateStage(
                    widget.stage.id,
                    posteController.text,
                    compagnieController.text,
                    adresseController.text,
                    dateDebutController.text,
                    dateFinController.text,
                    descriptionController.text,
                  );
                  setState(() {
                    successMessage = 'Update réussi!';
                  });
                },
                child: const Text('Enregistrer les modifications'),
              ),
              Text(
                successMessage,
                style: const TextStyle(
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}