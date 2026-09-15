import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:path/path.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:sqflite/sqflite.dart';

import 'data.dart';
import 'db.dart';
import 'button.dart';
import 'card.dart';
import 'forms.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }

  final database = openDatabase(
    join(await getDatabasesPath(), "crop_jobs.db"),
    onCreate: (db, version) {
      return db.execute(
        "CREATE TABLE jobs(id INTEGER PRIMARY KEY, crop TEXT, location TEXT, description TEXT, priority INTEGER)",
      );
    },
    version: 1,
  );

  insertJob(
    await database,
    JobData(
      id: 1,
      crop: "Plant",
      location: "45R",
      description: "trim etc.",
      priority: 2,
    ),
  );

  final jobs = await getJobs(await database);

  runApp(
    MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: .light,
        ),
        textTheme: TextTheme(
          displayLarge: const TextStyle(color: Colors.black, fontSize: 24),
          titleLarge: GoogleFonts.inter(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          titleMedium: GoogleFonts.inter(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
          titleSmall: GoogleFonts.inter(color: Colors.black, fontSize: 20),
          displayMedium: GoogleFonts.inter(fontSize: 20),
        ),
      ),
      home: SafeArea(
        child: MainPage(jobs: jobs, db: database),
      ),
    ),
  );
}

class TopBar extends StatefulWidget {
  const TopBar({super.key});

  @override
  State<TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> {
  bool wideScreen = false;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    wideScreen = width > 600;

    return Container(
      height: 150,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      child: Column(
        mainAxisAlignment: .spaceEvenly,
        children: [
          if (!wideScreen)
            Center(
              child: Text(
                "Thirkettle Nurseries",
                style: Theme.of(context).textTheme.displayLarge,
              ),
            ),
          Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              GreenButton(
                text: "Generate Job Sheet",
                icon: Icons.text_snippet,
                onPressed: () {},
              ),
              if (wideScreen)
                Expanded(
                  child: Center(
                    child: Text(
                      "Thirkettle Nurseries",
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                  ),
                ),
              OutlinedButton.icon(
                onPressed: () {},
                icon: Icon(Icons.account_circle, size: 40),
                iconAlignment: .end,
                label: Text(
                  "Account",
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                style: OutlinedButton.styleFrom(
                  padding: .symmetric(horizontal: 20, vertical: 15),
                ),
              ),
            ],
          ),
          Divider(height: 0),
        ],
      ),
    );
  }
}

class CardArea extends StatefulWidget {
  const CardArea({super.key, required this.database});

  final Future<Database> database;

  @override
  State<CardArea> createState() => _CardAreaState();
}

class _CardAreaState extends State<CardArea> {
  List<JobData> _jobs = [];
  late Future<Database> db;

  @override
  void initState() {
    super.initState();
    db = widget.database;
    _refreshCards();

    Timer.periodic(const Duration(seconds: 1), (timer) {
      _refreshCards();
    });
  }

  void _refreshCards() async {
    final jobs = await getJobs(await db);
    setState(() {
      _jobs = jobs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: .min,
      children: [
        Row(
          children: [
            GrayButton(
              text: "Create Job",
              onPressed: () async {
                insertJob(
                  await db,
                  JobData(
                    id: 2,
                    crop: "next plant",
                    location: "27L",
                    description: "do the stuff",
                    priority: 3,
                  ),
                );
              },
              icon: Icons.add,
            ),
          ],
        ),
        GridView.extent(
          shrinkWrap: true,
          maxCrossAxisExtent: 300,
          mainAxisExtent: 300,
          crossAxisSpacing: 36,
          mainAxisSpacing: 36,
          padding: .symmetric(horizontal: 20, vertical: 0),
          children: [
            for (final job in _jobs)
              JobCard(
                crop: job.crop,
                location: job.location,
                description: job.description,
                priority: job.priority,
                editCallback: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditPage(job: job, db: db),
                    ),
                  );
                },
              ),
          ],
        ),
      ],
    );
  }
}

class MainPage extends StatelessWidget {
  const MainPage({super.key, required this.jobs, required this.db});

  final List<JobData> jobs;
  final Future<Database> db;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        children: [
          TopBar(),
          CardArea(database: db),
        ],
      ),
    );
  }
}

class EditPage extends StatelessWidget {
  const EditPage({super.key, required this.job, required this.db});

  final JobData job;
  final Future<Database> db;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: JobFormEdit(job: job, database: db),
    );
  }
}
