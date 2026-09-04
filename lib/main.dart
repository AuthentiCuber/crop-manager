import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:path/path.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:sqflite/sqflite.dart';

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

  Future<void> insertJob(JobData job) async {
    final db = await database;

    await db.insert(
      "jobs",
      job.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateJob(JobData job) async {
    final db = await database;

    await db.update("jobs", job.toMap(), where: "id = ?", whereArgs: [job.id]);
  }

  Future<List<JobData>> getJobs() async {
    final db = await database;

    final List<Map<String, Object?>> jobMap = await db.query("jobs");

    return [
      for (final {
            "id": id as int,
            "crop": crop as String,
            "location": location as String,
            "description": description as String,
            "priority": priority as int,
          }
          in jobMap)
        JobData(
          id: id,
          crop: crop,
          location: location,
          description: description,
          priority: priority,
        ),
    ];
  }

  final jobs = await getJobs();

  runApp(
    MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.light,
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
      home: SafeArea(child: MyScaffold(jobs: jobs)),
    ),
  );
}

class Button extends StatelessWidget {
  const Button({
    required this.text,
    required this.icon,
    required this.onPressed,
    required this.colour,
    required this.textColour,
    super.key,
  });

  final String text;
  final VoidCallback onPressed;
  final IconData icon;
  final Color colour;
  final Color textColour;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      label: Text(
        text,
        style: GoogleFonts.inter(fontSize: 20, color: textColour),
      ),
      icon: Icon(icon, size: 24, color: textColour),
      style: FilledButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 13, horizontal: 13),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.all(Radius.circular(5)),
        ),
        backgroundColor: colour,
      ),
    );
  }
}

class GreenButton extends Button {
  const GreenButton({
    required super.text,
    required super.onPressed,
    required super.icon,
    super.key,
  }) : super(colour: Colors.green, textColour: Colors.white);
}

class GrayButton extends Button {
  const GrayButton({
    required super.text,
    required super.onPressed,
    required super.icon,
    super.key,
  }) : super(colour: Colors.grey, textColour: Colors.black);
}

class Card extends StatelessWidget {
  const Card({
    required this.crop,
    required this.location,
    required this.description,
    required this.priority,
    super.key,
  });

  final String crop;
  final String location;
  final String description;
  final int priority;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadiusGeometry.all(Radius.circular(14)),
        color: Colors.grey[300],
      ),
      padding: EdgeInsetsGeometry.symmetric(vertical: 20, horizontal: 20),
      child: Column(
        spacing: 2,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Text(
                  crop,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadiusDirectional.all(
                    Radius.circular(32),
                  ),
                  color: HSVColor.lerp(
                    HSVColor.fromAHSV(1, 0, 1, 0.7),
                    HSVColor.fromAHSV(1, 110, 1, 0.7),
                    (priority - 1) / 2,
                  )?.toColor(),
                ),
                child: Center(
                  child: Text(
                    priority.toString(),
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
          Text(location, style: Theme.of(context).textTheme.titleSmall),
          Expanded(
            child: Text(
              description,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Padding(
            padding: EdgeInsetsGeometry.only(bottom: 20, top: 10),
            child: Divider(height: 0),
          ),
          Center(
            child: GreenButton(
              text: "Edit",
              onPressed: () {},
              icon: Icons.edit,
            ),
          ),
        ],
      ),
    );
  }
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
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (!wideScreen)
            Center(
              child: Text(
                "Thirkettle Nurseries",
                style: Theme.of(context).textTheme.displayLarge,
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                iconAlignment: IconAlignment.end,
                label: Text(
                  "Account",
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsetsGeometry.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                ),
              ),
            ],
          ),
          Divider(height: 0),
          Row(
            children: [
              GrayButton(text: "Create Job", onPressed: () {}, icon: Icons.add),
            ],
          ),
        ],
      ),
    );
  }
}

final List<Card> cards = [
  Card(
    crop: "Sophora Dragons Gold/microphilia",
    location: "45R",
    description: "60cm cane",
    priority: 3,
  ),
  Card(
    crop: "Pitto Wrinkle Blue",
    location: "7R, 56R",
    description: "Trimming - 90cm 8/10mm",
    priority: 2,
  ),
  Card(
    crop: "Coprosma Kiwi Gold/Prostrata/Goldstream",
    location: "45R",
    description:
        "Trim back long shoots to pot rim edge and then do a bunch of random stuff",
    priority: 1,
  ),
  Card(
    crop: "Sophora Dragons Gold/microphilia",
    location: "45R",
    description: "60cm cane",
    priority: 3,
  ),
  Card(
    crop: "Pitto Wrinkle Blue",
    location: "7R, 56R",
    description: "Trimming - 90cm 8/10mm",
    priority: 2,
  ),
  Card(
    crop: "Coprosma Kiwi Gold/Prostrata/Goldstream",
    location: "45R",
    description: "Trim back long shoots to pot rim edge",
    priority: 1,
  ),
  Card(
    crop: "Sophora Dragons Gold/microphilia",
    location: "45R",
    description: "60cm cane",
    priority: 3,
  ),
  Card(
    crop: "Pitto Wrinkle Blue",
    location: "7R, 56R",
    description:
        "Trimming - 90cm 8/10mm and then do a bunch of other random stuff that needs to be done",
    priority: 2,
  ),
  Card(
    crop: "Coprosma Kiwi Gold/Prostrata/Goldstream",
    location: "45R",
    description: "Trim back long shoots to pot rim edge",
    priority: 1,
  ),
];

class JobData {
  final int id;
  final String crop;
  final String location;
  final String description;
  final int priority;

  const JobData({
    required this.id,
    required this.crop,
    required this.location,
    required this.description,
    required this.priority,
  });

  Map<String, Object?> toMap() {
    return {
      "id": id,
      "crop": crop,
      "location": location,
      "description": description,
      "priority": priority,
    };
  }
}

class MyScaffold extends StatelessWidget {
  const MyScaffold({super.key, required this.jobs});

  final List<JobData> jobs;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        children: [
          TopBar(),
          Expanded(
            child: GridView.extent(
              maxCrossAxisExtent: 300,
              mainAxisExtent: 300,
              crossAxisSpacing: 36,
              mainAxisSpacing: 36,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              children: [
                for (final job in jobs)
                  Card(
                    crop: job.crop,
                    location: job.location,
                    description: job.description,
                    priority: job.priority,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
