import 'package:sqflite/sqflite.dart' show Database;

import 'data.dart';

Future<void> insertJob(Database db, JobData job) async {
  await db.insert("jobs", job.toMap(), conflictAlgorithm: .replace);
}

Future<void> updateJob(Database db, JobData job) async {
  await db.update("jobs", job.toMap(), where: "id = ?", whereArgs: [job.id]);
}

Future<List<JobData>> getJobs(
  Database db, {
  String? where,
  List<Object?>? whereArgs,
}) async {
  final List<Map<String, Object?>> jobMap = await db.query(
    "jobs",
    where: where,
    whereArgs: whereArgs,
  );

  return [for (final job in jobMap) JobData.fromMap(job)];
}

Future<void> deleteJob(Database db, int jobId) async {
  await db.delete("jobs", where: "id = ?", whereArgs: [jobId]);
}
