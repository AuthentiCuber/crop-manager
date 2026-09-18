import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import 'data.dart';
import 'db.dart';
import 'button.dart';

class TextInput extends StatelessWidget {
  const TextInput({
    super.key,
    required this.label,
    required this.validator,
    required this.onChanged,
    required this.initialValue,
    required this.hint,
  });

  final String label;
  final FormFieldValidator<String> validator;
  final ValueChanged<String> onChanged;
  final String? initialValue;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        Padding(
          padding: .symmetric(vertical: 10),
          child: TextFormField(
            initialValue: initialValue,
            onChanged: onChanged,
            validator: validator,
            decoration: InputDecoration(hintText: hint),
          ),
        ),
      ],
    );
  }
}

String? requiredValidator(String? s) {
  if (s == null || s.isEmpty) return "This field is required";
  return null;
}

class JobFormEdit extends StatefulWidget {
  const JobFormEdit({super.key, required this.job, required this.database});

  final Future<Database> database;
  final JobData job;

  @override
  State<JobFormEdit> createState() => _JobFormEditState();
}

class _JobFormEditState extends State<JobFormEdit> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late Future<Database> db;
  JobData? job;

  @override
  void initState() {
    super.initState();
    db = widget.database;
    job = widget.job;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Padding(
            padding: .symmetric(vertical: 10),
            child: Text(
              "Update Job",
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          TextInput(
            label: "Crop name",
            validator: requiredValidator,
            onChanged: (value) {
              job!.crop = value;
            },
            initialValue: job!.crop,
            hint: "Coprosma Gold",
          ),
          TextInput(
            label: "Job description",
            validator: requiredValidator,
            onChanged: (value) {
              job!.description = value;
            },
            initialValue: job!.description,
            hint: "Trim, water",
          ),
          TextInput(
            label: "Crop location",
            validator: requiredValidator,
            onChanged: (value) {
              job!.location = value;
            },
            initialValue: job!.location,
            hint: "45R, 27L",
          ),
          TextInput(
            label: "Job priority",
            validator: (String? val) {
              if (val == null ||
                  val.isEmpty ||
                  int.tryParse(val) == null ||
                  val.length != 1) {
                return "Priority should be a single digit number!";
              }
              return null;
            },
            onChanged: (value) {
              if (!_formKey.currentState!.validate()) return;
              job!.priority = int.parse(value);
            },
            initialValue: job!.priority.toString(),
            hint: "1, 2, 3",
          ),
          Padding(
            padding: .symmetric(vertical: 20),
            child: Row(
              mainAxisAlignment: .spaceEvenly,
              children: [
                GreenButton(
                  text: "Update",
                  onPressed: () {
                    if (!_formKey.currentState!.validate()) return;

                    () async {
                      updateJob(await db, job!);
                    }();

                    Navigator.pop(context);
                  },
                  icon: Icons.check,
                ),
                RedButton(
                  text: "Delete",
                  onPressed: () {
                    () async {
                      deleteJob(await db, job!.id);
                    }();
                    Navigator.pop(context);
                  },
                  icon: Icons.delete,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class JobFormCreate extends StatefulWidget {
  const JobFormCreate({super.key, required this.database});

  final Future<Database> database;

  @override
  State<JobFormCreate> createState() => _JobFormCreateState();
}

class _JobFormCreateState extends State<JobFormCreate> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late Future<Database> db;
  var job = JobData(
    id: 0,
    crop: "",
    location: "",
    description: "",
    priority: 1,
  );

  @override
  void initState() {
    super.initState();
    db = widget.database;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Padding(
            padding: .symmetric(vertical: 10),
            child: Text(
              "Create Job",
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          TextInput(
            label: "Crop name",
            validator: requiredValidator,
            onChanged: (value) {
              job.crop = value;
            },
            initialValue: null,
            hint: "Coprosma Gold",
          ),
          TextInput(
            label: "Job description",
            validator: requiredValidator,
            onChanged: (value) {
              job.description = value;
            },
            initialValue: null,
            hint: "Trim, water",
          ),
          TextInput(
            label: "Crop location",
            validator: requiredValidator,
            onChanged: (value) {
              job.location = value;
            },
            initialValue: null,
            hint: "45R, 27L",
          ),
          TextInput(
            label: "Job priority",
            onChanged: (value) {
              if (!_formKey.currentState!.validate()) return;
              job.priority = int.parse(value);
            },
            validator: (String? val) {
              if (val == null ||
                  val.isEmpty ||
                  int.tryParse(val) == null ||
                  val.length != 1) {
                return "Priority should be a single digit number!";
              }
              return null;
            },
            initialValue: null,
            hint: "1, 2, 3",
          ),
          Padding(
            padding: .symmetric(vertical: 20),
            child: GreenButton(
              text: "Create Job",
              onPressed: () {
                if (!_formKey.currentState!.validate()) return;

                () async {
                  insertJob(await db, job);
                }();

                Navigator.pop(context);
              },
              icon: Icons.add,
            ),
          ),
        ],
      ),
    );
  }
}
