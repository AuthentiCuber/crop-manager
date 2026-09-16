import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import 'data.dart';
import 'db.dart';
import 'button.dart';

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
          TextFormField(
            initialValue: job!.crop,
            onChanged: (value) {
              job!.crop = value;
            },
          ),
          TextFormField(
            initialValue: job!.description,
            onChanged: (value) {
              job!.description = value;
            },
          ),
          TextFormField(
            initialValue: job!.location,
            onChanged: (value) {
              job!.location = value;
            },
          ),
          TextFormField(
            initialValue: job!.priority.toString(),
            onChanged: (value) {
              if (!_formKey.currentState!.validate()) return;
              job!.priority = int.parse(value);
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
          ),
          Row(
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
          TextFormField(
            onChanged: (value) {
              job.crop = value;
            },
          ),
          TextFormField(
            onChanged: (value) {
              job.description = value;
            },
          ),
          TextFormField(
            onChanged: (value) {
              job.location = value;
            },
          ),
          TextFormField(
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
          ),
          GreenButton(
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
        ],
      ),
    );
  }
}
