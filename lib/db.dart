import 'package:sqflite/sqflite.dart' show Database, ConflictAlgorithm;

import 'data.dart';

Future<void> insertJob(Database db, JobData job) async {
  await db.insert(
    "jobs",
    job.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

Future<void> updateJob(Database db, JobData job) async {
  await db.update("jobs", job.toMap(), where: "id = ?", whereArgs: [job.id]);
}

Future<List<JobData>> getJobs(Database db) async {
  final List<Map<String, Object?>> jobMap = await db.query("jobs");

  return [for (final job in jobMap) JobData.fromMap(job)];
}
