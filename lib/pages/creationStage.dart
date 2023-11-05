import 'package:flutter/material.dart';
import '/authentication.dart';
import 'package:intl/intl.dart';
import '../menus/menu_employeur.dart';


class CreationStage extends StatefulWidget {
  const CreationStage({super.key});

  @override
  _CreationStageState createState() => _CreationStageState();
}

class _CreationStageState extends State<CreationStage> {
  final TextEditingController posteController = TextEditingController();
  final TextEditingController compagnieController = TextEditingController();
  final TextEditingController adresseController = TextEditingController();
  final TextEditingController dateDebutController = TextEditingController();
  final TextEditingController dateFinController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  late DateTime selectedDate;
  String message = '';
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Ajouter un Stage'),
      ),
      body: Center(
        child: Container(
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
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  String poste = posteController.text;
                  String compagnie = compagnieController.text;
                  String adresse = adresseController.text;
                  String description = descriptionController.text;
                  String dateDebut = dateDebutController.text;
                  String dateFin = dateFinController.text;

                  if (poste.isEmpty ||
                      compagnie.isEmpty ||
                      adresse.isEmpty ||
                      description.isEmpty ||
                      dateDebut.isEmpty ||
                      dateFin.isEmpty) {
                    setState(() {
                      message = 'Veuillez remplir tous les champs.';
                    });
                  } else {
                    addStage(context, poste, compagnie, adresse, dateDebut,
                        dateFin, description);
                    setState(() {
                      message = 'Stage ajouté!';
                    });

                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MenuEmployeur()));
                  }
                },
                child: const Text('Ajouter le Stage'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
