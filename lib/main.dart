import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:path/path.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:sqflite/sqflite.dart';

import 'package:provider/provider.dart';

import 'data.dart';
import 'db.dart';
import 'button.dart';
import 'card.dart';
import 'forms.dart';

void main() async {
  // required for database stuff
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }

  final database = openDatabase(
    join(await getDatabasesPath(), "crop_jobs.db"),
    onCreate: (db, version) {
      return db.execute(
        "CREATE TABLE jobs(id INTEGER PRIMARY KEY AUTOINCREMENT, crop TEXT, location TEXT, description TEXT, priority INTEGER, is_completed INTEGER, assigned INTEGER)",
      );
    },
    version: 1,
  );

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
      home: SafeArea(child: MainPage(db: database)),
    ),
  );
}

class TopBar extends StatefulWidget {
  const TopBar({super.key, required this.database});

  final Future<Database> database;

  @override
  State<TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> {
  late Future<Database> db;

  bool wideScreen = false;

  @override
  void initState() {
    super.initState();
    db = widget.database;
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    wideScreen = width > 600;

    return Container(
      padding: .symmetric(horizontal: 10),
      child: Column(
        children: [
          if (!wideScreen)
            Center(
              child: Text(
                "Thirkettle Nurseries",
                style: Theme.of(context).textTheme.displayLarge,
              ),
            ),
          Padding(
            padding: .symmetric(vertical: 15),
            child: Consumer<AccountModel>(
              builder: (context, account, child) {
                return Row(
                  mainAxisAlignment: .spaceBetween,
                  children: [
                    if (account.type == .manager)
                      GreenButton(
                        text: "Generate Job Sheet",
                        icon: Icons.text_snippet,
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GenJobListPage(db: db),
                          ),
                        ),
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
                      onPressed: () {
                        account.setType(
                          account.type == .manager ? .worker : .manager,
                        );
                      },
                      icon: Icon(Icons.account_circle, size: 40),
                      iconAlignment: .end,
                      label: Text(
                        account.type == .manager ? "Manager" : "Worker",
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: .symmetric(horizontal: 20, vertical: 15),
                      ),
                    ),
                  ],
                );
              },
            ),
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
    Timer.periodic(Duration(seconds: 1), (timer) => _refreshCards());
  }

  void _refreshCards() async {
    final accountType = Provider.of<AccountModel>(
      this.context,
      listen: false,
    ).type;
    final jobs = await getJobs(
      await db,
      where: accountType == .worker ? "assigned = 1" : null,
    );
    setState(() {
      _jobs = jobs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: .symmetric(horizontal: 20, vertical: 20),
          child: Consumer<AccountModel>(
            builder: (context, account, child) {
              return Row(
                children: [
                  if (account.type == .manager)
                    GrayButton(
                      text: "Create Job",
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => JobCreatePage(db: db),
                        ),
                      ),
                      icon: Icons.add,
                    ),
                ],
              );
            },
          ),
        ),
        GridView.extent(
          shrinkWrap: true,
          maxCrossAxisExtent: 350,
          mainAxisExtent: 300,
          crossAxisSpacing: 36,
          mainAxisSpacing: 36,
          padding: .symmetric(horizontal: 20, vertical: 0),
          children: [
            for (final job in _jobs)
              DefaultJobCard(
                job: job,
                editPageRoute: MaterialPageRoute(
                  builder: (context) => JobEditPage(job: job, db: db),
                ),
                toggleDoneCallback: () async {
                  updateJob(
                    await db,
                    JobData(
                      id: job.id,
                      crop: job.crop,
                      location: job.location,
                      description: job.description,
                      priority: job.priority,
                      isCompleted: 1 - job.isCompleted,
                      assigned: job.assigned,
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

class JobSelectorCards extends StatefulWidget {
  const JobSelectorCards({super.key, required this.db});

  final Future<Database> db;

  @override
  State<StatefulWidget> createState() => _JobSelectorCardsState();
}

class _JobSelectorCardsState extends State<JobSelectorCards> {
  late Future<Database> _db;

  List<JobData> _jobs = [];

  @override
  void initState() {
    super.initState();
    _db = widget.db;
    _getJobs();
  }

  void _getJobs() async {
    final jobs = await getJobs(await _db, where: "is_completed = 0");
    setState(() {
      _jobs = jobs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GridView.extent(
      shrinkWrap: true,
      maxCrossAxisExtent: 350,
      mainAxisExtent: 300,
      crossAxisSpacing: 36,
      mainAxisSpacing: 36,
      padding: .symmetric(horizontal: 20, vertical: 0),
      children: [for (final job in _jobs) JobSelectorCard(job: job)],
    );
  }
}

class MainPage extends StatelessWidget {
  const MainPage({super.key, required this.db});

  final Future<Database> db;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: ChangeNotifierProvider(
        create: (context) => AccountModel(),
        child: Column(
          children: [
            TopBar(database: db),
            CardArea(database: db),
          ],
        ),
      ),
    );
  }
}

class JobEditPage extends StatelessWidget {
  const JobEditPage({super.key, required this.job, required this.db});

  final JobData job;
  final Future<Database> db;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(
        child: SizedBox(
          width: 600,
          height: 600,
          child: JobFormEdit(job: job, database: db),
        ),
      ),
    );
  }
}

class JobCreatePage extends StatelessWidget {
  const JobCreatePage({super.key, required this.db});

  final Future<Database> db;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(
        child: SizedBox(
          width: 600,
          height: 600,
          child: JobFormCreate(database: db),
        ),
      ),
    );
  }
}

class GenJobListPage extends StatelessWidget {
  const GenJobListPage({super.key, required this.db});

  final Future<Database> db;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: ChangeNotifierProvider<JobList>(
        create: (context) => JobList(),
        child: Column(
          children: [
            Padding(
              padding: .symmetric(horizontal: 20, vertical: 20),
              child: Row(
                spacing: 20,
                children: [
                  Consumer<JobList>(
                    builder: (context, joblist, child) => GreenButton(
                      text: "Generate",
                      onPressed: () async {
                        for (final job in joblist.items) {
                          await updateJob(
                            await db,
                            JobData(
                              id: job.id,
                              crop: job.crop,
                              location: job.location,
                              description: job.description,
                              priority: job.priority,
                              isCompleted: job.isCompleted,
                              assigned: 1 - job.assigned,
                            ),
                          );
                        }
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                      icon: Icons.done,
                    ),
                  ),
                  GrayButton(
                    text: "Cancel",
                    onPressed: () => Navigator.pop(context),
                    icon: Icons.cancel,
                  ),
                ],
              ),
            ),
            JobSelectorCards(db: db),
          ],
        ),
      ),
    );
  }
}
